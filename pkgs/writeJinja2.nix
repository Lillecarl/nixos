{
  stdenvNoCC,
  writeTextFile,
  writers,
  jinja2,
}:
{
  name,
  template, # storepath or string
  variables, # attrset that goes through JSON serialization and deserialization to be used in the Jinja template
  environment ? { }, # https://jinja.palletsprojects.com/en/stable/api/#high-level-api see class jinja2.Environment
}:
let
  jinjaRenderer =
    writers.writePython3 "jinjaRenderer"
      {
        libraries = [ jinja2 ];
      }
      ''
        import sys
        import json
        import jinja2
        from pathlib import Path

        try:
            template_path = Path(sys.argv[1])
            variables_path = Path(sys.argv[2])
            env_attrs_path = Path(sys.argv[3])
            output_path = Path(sys.argv[4])

            env_attrs = json.loads(env_attrs_path.read_text())

            # Handle undefined parameter from JSON
            # Default to StrictUndefined since we're calling from Nix after all
            undefined = env_attrs.get("undefined")
            if undefined is None:
                env_attrs["undefined"] = jinja2.StrictUndefined
            else:
                if undefined == "Undefined":
                    env_attrs["undefined"] = jinja2.Undefined
                elif undefined == "DebugUndefined":
                    env_attrs["undefined"] = jinja2.DebugUndefined
                elif undefined == "ChainableUndefined":
                    env_attrs["undefined"] = jinja2.ChainableUndefined

            # Set the loader
            env_attrs['loader'] = jinja2.FileSystemLoader(template_path.parent)

            env = jinja2.Environment(**env_attrs)
            template = env.get_template(template_path.name)

            variables = json.loads(variables_path.read_text())

            rendered = template.render(variables)

            output_path.write_text(rendered)

        except jinja2.TemplateSyntaxError as e:
            print(f"Template syntax error in {e.filename}:")
            print(f"  Line {e.lineno}: {e.message}")
            print(f"  Full error: {e}")
            sys.exit(1)
        except jinja2.UndefinedError as e:
            print(f"Undefined variable error: {e}")
            sys.exit(1)
        except Exception as e:
            print(f"Generic error: {e}")
            sys.exit(1)
      '';
  templateFile =
    if builtins.typeOf template == "string" then
      writeTextFile {
        name = "${name}-template-j2";
        text = template;
      }
    else
      template;
  variablesJSON = writeTextFile {
    name = "${name}-variables-json";
    text = builtins.toJSON variables;
  };
  environmentJSON = writeTextFile {
    name = "${name}-environment-json";
    text = builtins.toJSON environment;
  };
  file = stdenvNoCC.mkDerivation {
    inherit name;
    phases = [ "buildPhase" ];
    src = templateFile;
    buildPhase = # bash
      ''
        ${jinjaRenderer} $src ${variablesJSON} ${environmentJSON} $out 
      '';
  };
in
file
// {
  passthru = file.passthru // {
    text = builtins.readFile file;
    inherit variablesJSON;
    inherit environmentJSON;
  };
}
