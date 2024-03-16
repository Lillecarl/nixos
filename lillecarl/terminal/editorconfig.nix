_:
{
  editorconfig = {
    enable = true;

    settings = {
      "*" = {
        charset = "utf-8";
        end_of_line = "lf";
        trim_trailing_whitespace = true;
        insert_final_newline = true;
        indent_style = "space";
        indent_size = 2;
      };
      "*.py" = {
        indent_size = 4;
      };
      "*.fish" = {
        indent_size = 4;
      };
      "*.rs" = {
        indent_size = 4;
      };
    };
  };
}
