function filterJSON(dataset, filterExpression) {
  let translated = translateFilterHelpers(filterExpression);
  let filterExpressionProcessed = preprocessFilterExpression(translated);
  let jsonFrame = filterData(dataset, filterExpressionProcessed);
  return(jsonFrame);
}

// JS identifiers that must never receive the `item.` prefix.
const filterReservedWords = ['null', 'undefined', 'true', 'false', 'NaN', 'Infinity'];

function preprocessFilterExpression(filterExpression) {
  const regex = /(\b[a-zA-Z_]\w*\b)(?=(?:(?:[^'"\\]*["'][^'"\\]*["'])*[^'"\\]*$)(?![\'\.]))/g;
  const processedExpression = filterExpression.replace(regex, (match) => {
    if (/['"]/.test(match)) {
      return match;
    }
    if (filterReservedWords.indexOf(match) !== -1) {
      return match;
    }
    return 'item.' + match;
  });
  return replaceCommaWithAmpersand(processedExpression);
}

function filterData(data, filterExpression) {
  const expression = new Function('item', `return ${filterExpression}`);
  return data.filter(expression);
}

function replaceCommaWithAmpersand(inputString) {
  if (inputString.includes(',')) {
      return inputString.replace(/,/g, '&');
  }
  return inputString;
}

// Translate dplyr filter helpers (is.na, between) emitted by the R side into
// plain JavaScript. Runs before column prefixing so inner column references are
// prefixed afterwards, and before commas become `&` so helper argument commas
// are consumed here.
function translateFilterHelpers(expression) {
  let result = translateFilterCall(expression, 'is.na(', function(args) {
    let value = args[0].trim();
    return '((' + value + ') === null || (' + value + ') === undefined)';
  });
  result = translateFilterCall(result, 'between(', function(args) {
    let value = args[0].trim();
    let lower = args[1].trim();
    let upper = args[2].trim();
    return '((' + value + ') >= (' + lower + ') && (' + value + ') <= (' + upper + '))';
  });
  return result;
}

// Replace every occurrence of `token`(...) with the result of `build(args)`,
// where args are split on top-level commas respecting nested parens and strings.
// Processes innermost trailing calls first so nested helpers translate correctly.
function translateFilterCall(expression, token, build) {
  let result = expression;
  let safety = 0;

  while (result.indexOf(token) !== -1 && safety < 100) {
    safety++;
    let start = result.lastIndexOf(token);
    let argsStart = start + token.length;
    let parsed = splitFilterArgs(result, argsStart);

    if (parsed === null) {
      break;
    }

    let replacement = build(parsed.parts);
    result = result.substring(0, start) + replacement + result.substring(parsed.end + 1);
  }

  return result;
}

// Split call arguments starting at argsStart (first char after the open paren),
// respecting nested parentheses and quoted strings.
// Returns { parts: [...], end: index of matching ')' } or null on failure.
function splitFilterArgs(str, argsStart) {
  let depth = 1;
  let parts = [];
  let current = '';
  let i = argsStart;

  while (i < str.length && depth > 0) {
    let ch = str[i];

    if (ch === "'" || ch === '"') {
      let quote = ch;
      current += ch;
      i++;
      while (i < str.length && str[i] !== quote) {
        if (str[i] === '\\') {
          current += str[i];
          i++;
        }
        current += str[i];
        i++;
      }
      if (i < str.length) {
        current += str[i];
      }
      i++;
      continue;
    }

    if (ch === '(') {
      depth++;
      current += ch;
    } else if (ch === ')') {
      depth--;
      if (depth === 0) {
        parts.push(current);
        break;
      }
      current += ch;
    } else if (ch === ',' && depth === 1) {
      parts.push(current);
      current = '';
    } else {
      current += ch;
    }
    i++;
  }

  if (depth !== 0) {
    return null;
  }

  return { parts: parts, end: i };
}
