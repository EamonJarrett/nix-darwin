{ lib, python3Packages, fetchPypi }:

# graphifyy on PyPI; CLI entrypoint is `graphify`.
# Tree-sitter language deps are lazy-imported per-language inside extractor
# functions. nixpkgs only ships a subset of the grammars graphify lists, so
# we relax the missing ones — extraction still works for Python, JavaScript,
# Rust, C#, and SQL. Other languages will raise ImportError at extract-time
# until their tree-sitter-* grammar lands in nixpkgs (or is added here).
python3Packages.buildPythonApplication rec {
  pname = "graphifyy";
  version = "0.7.6";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-3zcRMw0MXJSOHOMI0Arx1zrnfGprVhokhVTJLcDiD4M=";
  };

  build-system = [ python3Packages.setuptools ];

  pythonRelaxDeps = [
    "tree-sitter-typescript"
    "tree-sitter-go"
    "tree-sitter-java"
    "tree-sitter-c"
    "tree-sitter-cpp"
    "tree-sitter-ruby"
    "tree-sitter-kotlin"
    "tree-sitter-scala"
    "tree-sitter-php"
    "tree-sitter-swift"
    "tree-sitter-lua"
    "tree-sitter-zig"
    "tree-sitter-powershell"
    "tree-sitter-elixir"
    "tree-sitter-objc"
    "tree-sitter-julia"
    "tree-sitter-verilog"
    "tree-sitter-fortran"
  ];

  pythonRemoveDeps = pythonRelaxDeps;

  dependencies = with python3Packages; [
    networkx
    datasketch
    rapidfuzz
    tree-sitter
    tree-sitter-python
    tree-sitter-javascript
    tree-sitter-rust
    tree-sitter-c-sharp
  ];

  pythonImportsCheck = [ "graphify" ];

  meta = {
    description = "Turn any folder of code/docs/papers/images into a queryable knowledge graph";
    homepage = "https://github.com/safishamsi/graphify";
    license = lib.licenses.mit;
    mainProgram = "graphify";
    platforms = lib.platforms.unix;
  };
}
