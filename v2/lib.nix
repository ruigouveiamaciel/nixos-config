{inputs, ...}: let
  myLib = (import ./lib.nix) {inherit inputs;};
  inherit (inputs.self) outputs;
in rec {
  # ======================= Package Helpers ======================== #

  pkgsFor = sys: inputs.nixpkgs.legacyPackages.${sys};

  pkgsForAllSystems = f:
    forAllSystems (system:
      f {
        inherit system;
        pkgs = pkgsFor system;
      });

  # ========================== Buildables ========================== #

  mkSystem = config:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs outputs myLib;
      };
      modules = [
        config
        outputs.nixosModules.default
      ];
    };

  mkHome = sys: config:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = pkgsFor sys;
      extraSpecialArgs = {
        inherit inputs myLib outputs;
      };
      modules = [
        config
        outputs.homeManagerModules.default
      ];
    };

  # =========================== Helpers ============================ #

  filesIn = dir: (map (fname: dir + "/${fname}")
    (builtins.attrNames (builtins.readDir dir)));

  dirsIn = dir:
    inputs.nixpkgs.lib.filterAttrs (_: value: value == "directory")
    (builtins.readDir dir);

  fileNameOf = path: (builtins.head (builtins.split "\\." (baseNameOf path)));

  # ========================== Extenders =========================== #

  # Evaluates nixos/home-manager module and extends it's options / config
  extendModule = {path, ...} @ args: {pkgs, ...} @ margs:
    if !builtins.isPath path
    then builtins.throw "Error: Expected a path, but got ${builtins.typeOf path}"
    else let
      eval =
        if (builtins.isString path) || (builtins.isPath path)
        then import path margs
        else path margs;
      extra =
        if (builtins.hasAttr "extraOptions" args) || (builtins.hasAttr "extraConfig" args)
        then [
          (_: {
            options = args.extraOptions or {};
            config = args.extraConfig or {};
          })
        ]
        else [];
    in {
      imports =
        (eval.imports or [])
        ++ extra;

      options =
        if builtins.hasAttr "optionsExtension" args
        then (args.optionsExtension (eval.options or {}))
        else (eval.options or {});

      config =
        if builtins.hasAttr "configExtension" args
        then (args.configExtension (eval.config or {}))
        else (eval.config or {});
    };

  extendModules = extension: modules:
    map (f: extendModule (extension f)) modules;

  resolveDir = dir:
    if !builtins.isPath dir
    then builtins.throw "Error: Expected a path, but got ${builtins.typeOf dir}"
    else let
      content = builtins.readDir dir;
      isBracketed = name: inputs.nixpkgs.lib.hasPrefix "[" name && inputs.nixpkgs.lib.hasSuffix "]" name;
      isNotBracketed = name: !isBracketed name;
      isModule = name: type: type == "regular" || (type == "directory" && isNotBracketed name);
      isCategory = name: type: type == "directory" && isBracketed name;
      getCategoryName = str: let
        len = builtins.stringLength str;
      in
        if len > 2
        then builtins.substring 1 (len - 2) str
        else "";
      files = builtins.attrNames (inputs.nixpkgs.lib.filterAttrs isModule content);
      categories = builtins.attrNames (inputs.nixpkgs.lib.filterAttrs isCategory content);
      subFiles = builtins.concatLists (
        builtins.map (category:
          builtins.map (mod:
            mod
            // {
              name =
                if (fileNameOf mod.name) == "default"
                then getCategoryName category
                else "${getCategoryName category}.${mod.name}";
            }) (resolveDir (dir + "/${category}")))
        categories
      );
    in
      builtins.map (fileName: {
        name = fileNameOf fileName;
        path = dir + "/${fileName}";
      })
      files
      ++ subFiles;

  # ============================ Shell ============================= #

  forAllSystems = let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  in
    inputs.nixpkgs.lib.genAttrs systems;
}
