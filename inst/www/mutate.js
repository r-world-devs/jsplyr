function mutateJSON(dataset, expressions) {
  return dataset.map(function(item) {
    let newItem = Object.assign({}, item);
    expressions.forEach(function(expr) {
      let translated = translateExpression(expr.expression);
      let processedExpression = preprocessMutateExpression(translated, newItem);
      let fn = new Function('item', 'return ' + processedExpression);
      newItem[expr.name] = fn(newItem);
    });
    return newItem;
  });
}

// Translate an R mutate expression into a JS expression.
// Handles case_when() and ifelse()/if_else() conditional translation.
function translateExpression(expression) {
  var result = normalizeIfElseAlias(expression);
  result = translateCaseWhen(result);
  result = translateIfelse(result);
  return result;
}

// dplyr's if_else() behaves like base ifelse() for translation purposes.
// Rewrite the token so the shared ifelse translator handles both.
function normalizeIfElseAlias(expression) {
  return expression.replace(/\bif_else\s*\(/g, 'ifelse(');
}

function preprocessMutateExpression(expression, item) {
  const keys = Object.keys(item);
  // Sort by length descending to avoid partial replacements
  keys.sort(function(a, b) { return b.length - a.length; });

  let result = expression;
  keys.forEach(function(key) {
    // Replace column names with item.column, avoiding matches inside strings or already prefixed
    let regex = new RegExp('(?<![\\w\\.\'"])\\b' + key + '\\b(?![\'"])', 'g');
    result = result.replace(regex, 'item.' + key);
  });
  return result;
}

// Translate R case_when(cond ~ value, ...) to chained JS ternary operators.
// case_when(a ~ x, b ~ y, TRUE ~ z) becomes ((a) ? (x) : ((b) ? (y) : (z))).
// Conditions left unmatched (no TRUE ~ branch) yield null, matching dplyr's NA default.
function translateCaseWhen(expression) {
  var token = 'case_when(';
  var result = expression;
  var safety = 0;

  while (result.indexOf(token) !== -1 && safety < 50) {
    safety++;
    var start = result.indexOf(token);
    var argsStart = start + token.length;
    var split = splitTopLevelArgs(result, argsStart);

    if (split === null) {
      break;
    }

    var replacement = buildCaseWhenTernary(split.parts);
    result = result.substring(0, start) + replacement + result.substring(split.end + 1);
  }

  return result;
}

// Build a nested ternary from case_when clauses (each "cond ~ value").
function buildCaseWhenTernary(clauses) {
  var parsed = clauses
    .map(function(clause) { return clause.trim(); })
    .filter(function(clause) { return clause.length > 0; })
    .map(splitCaseWhenClause)
    .filter(function(clause) { return clause !== null; });

  var ternary = 'null';
  for (var i = parsed.length - 1; i >= 0; i--) {
    var cond = parsed[i].cond.trim();
    var value = translateExpression(parsed[i].value.trim());
    // dplyr uses TRUE as the catch-all; map it to a JS truthy literal.
    if (cond === 'TRUE' || cond === 'T') {
      cond = 'true';
    } else {
      cond = translateExpression(cond);
    }
    ternary = '((' + cond + ') ? (' + value + ') : ' + ternary + ')';
  }

  return ternary;
}

// Split a single "cond ~ value" clause on the top-level ~ (respecting parens/strings).
function splitCaseWhenClause(clause) {
  var depth = 0;
  var i = 0;

  while (i < clause.length) {
    var ch = clause[i];

    if (ch === "'" || ch === '"') {
      var quote = ch;
      i++;
      while (i < clause.length && clause[i] !== quote) {
        if (clause[i] === '\\') {
          i++;
        }
        i++;
      }
      i++;
      continue;
    }

    if (ch === '(') {
      depth++;
    } else if (ch === ')') {
      depth--;
    } else if (ch === '~' && depth === 0) {
      return {
        cond: clause.substring(0, i),
        value: clause.substring(i + 1)
      };
    }
    i++;
  }

  return null;
}

// Split comma-separated arguments at the top level, respecting nested
// parentheses and strings. argsStart points to the first char after '('.
// Returns { parts: [...], end: index of closing ')' } or null on failure.
function splitTopLevelArgs(str, argsStart) {
  var depth = 1;
  var parts = [];
  var current = '';
  var i = argsStart;

  while (i < str.length && depth > 0) {
    var ch = str[i];

    if (ch === "'" || ch === '"') {
      var quote = ch;
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
        current += str[i]; // closing quote
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

// Translate R ifelse(cond, yes, no) to JS ((cond) ? (yes) : (no)).
// Supports nested ifelse calls and expressions with parentheses.
function translateIfelse(expression) {
  var ifelseToken = 'ifelse(';
  var result = expression;
  var safety = 0;

  while (result.indexOf(ifelseToken) !== -1 && safety < 50) {
    safety++;
    var start = result.indexOf(ifelseToken);
    var argsStart = start + ifelseToken.length;
    var args = splitIfelseArgs(result, argsStart);

    if (args === null) {
      break;
    }

    var cond = translateIfelse(args.parts[0].trim());
    var yes  = translateIfelse(args.parts[1].trim());
    var no   = translateIfelse(args.parts[2].trim());

    var replacement = '((' + cond + ') ? (' + yes + ') : (' + no + '))';
    result = result.substring(0, start) + replacement + result.substring(args.end + 1);
  }

  return result;
}

// Split the three arguments of ifelse(...) respecting nested parentheses and strings.
// argsStart points to the first character after 'ifelse('.
// Returns { parts: [cond, yes, no], end: index of closing ')' } or null on failure.
function splitIfelseArgs(str, argsStart) {
  var depth = 1;
  var parts = [];
  var current = '';
  var i = argsStart;

  while (i < str.length && depth > 0) {
    var ch = str[i];

    if (ch === "'" || ch === '"') {
      var quote = ch;
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
        current += str[i]; // closing quote
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

  if (parts.length !== 3) {
    return null;
  }

  return { parts: parts, end: i };
}
