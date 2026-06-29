# compute_steps are updated in the object

    Code
      print(tbl_lazy_json)
    Output
      # Source:     JSON array <`test data`>
      # Lazy:       not yet computed (call collect() to retrieve data)
      # Pipeline:
      #   filter(age >= 30)
      #   select(name)
      #   distinct()

---

    Code
      show_query(tbl_lazy_json)
    Output
      <Compute steps>
      [filter], <age >= 30>
      [select], <name>
      [distinct], <character(0), FALSE>

# print shows source, lazy status and pipeline

    Code
      print(tbl)
    Output
      # Source:     JSON array <`mtcars`>
      # Lazy:       not yet computed (call collect() to retrieve data)
      # Pipeline:
      #   filter(item.mpg >= 20)
      #   select(mpg, cyl)
      #   distinct()

# print renders mutate, summarise and join steps

    Code
      print(tbl)
    Output
      # Source:     JSON array <`mtcars`>
      # Lazy:       not yet computed (call collect() to retrieve data)
      # Pipeline:
      #   group_by(cyl)
      #   mutate(double_mpg = item.mpg * 2)
      #   summarise(mean_mpg = mean(mpg))

# group_by and summarise show_query output

    Code
      show_query(tbl)
    Output
      <Compute steps>
      [group_by], <c("city", "am")>
      [summarise], <list(list(name = "mean_age", fn = "mean", column = "age"), list(name = "count", fn = "n", column = ""))>

