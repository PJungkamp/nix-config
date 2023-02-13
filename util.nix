{ nixpkgs, home-manager }:
let
  # helper functions
  inherit (nixpkgs.lib.attrsets) nameValuePair;
  inherit (nixpkgs.lib.strings) splitString;
  inherit (nixpkgs.lib) mkForce;
  inherit (builtins) mapAttrs listToAttrs attrNames getAttr elem elemAt length filter;

  attrsToList =
    attrset: map
    (name: {
      inherit name;
      value = (getAttr name attrset);
    })
    (attrNames attrset);

  splitUserHost =
    name:
    let
      x = splitString "@" name;
      userName = elemAt x 0;
      hostName = if (length x) > 1 then elemAt x 1 else null;
    in { inherit userName hostName; };

  splitHostSystem =
    name:
    let
      checkLength = list:
        if length list == 2
        then list
        else throw "Invalid host '${name}'. Hosts must be of the form name@system, e.g. hostname@linux-x86_64.";
      x = checkLength (splitString "@" name);
      hostName = elemAt x 0;
      system = elemAt x 1;
    in { inherit hostName system; };

  usersForHost =
    host: users:
    listToAttrs
      (map
        ({ name, value }:
          let inherit (splitUserHost name) userName;
          in nameValuePair userName value)
        (filter
          ({ name, ... }:
            let inherit (splitUserHost name) userName hostName;
            in hostName == host || hostName == null && !elem "${userName}@${host}" (attrNames users))
          (attrsToList users)));

  mkUserModule = username: import ./users/${username}.nix;

  mkHostModule = hostname: import ./hosts/${hostname}.nix;

  mkUserModules =
    usernames: listToAttrs
    (map (name: nameValuePair name (mkUserModule name)) usernames);

  mkHostModules =
    hostnames: listToAttrs
    (map (name: nameValuePair name (mkHostModule name)) hostnames);

  mkHomeConfiguration =
    { userModule, hostName, inputs }:
    home-manager.lib.homeManagerConfiguration {
      extraSpecialArgs = inputs // { inherit hostName; system = null; };
      modules = [
        userModule
      ];
    };

  mkNixosConfiguration =
    { hostName, system, userModules, hostModule, inputs }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = inputs // { inherit hostName system; };
      modules = [
        # set system for nixpkgs
        { config.nixpkgs.hostPlatform = system; }
        # configure the host
        hostModule
        # add home-manager
        inputs.home-manager.nixosModules.home-manager
        # configure home-manager for all users
        ({ config, ... }: {
          config.home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users = usersForHost hostName userModules;
            extraSpecialArgs = inputs // { inherit hostName system; };
            sharedModules = [
              { config.home.stateVersion = mkForce config.system.stateVersion; }
            ];
          };
        })
      ];
    };

  mkHomeConfigurations =
    { userModules, inputs }:
    mapAttrs
      (name: userModule:
      let inherit (splitUserHost name) userName hostName;
      in mkHomeConfiguration { inherit userName hostName userModule inputs; })
      userModules;

  mkNixosConfigurations =
    { userModules, hostModules, inputs }:
    listToAttrs (map 
      ({ name, value }:
      let
        inherit (splitHostSystem name) hostName system;
        hostModule = value;
      in nameValuePair
        hostName
        (mkNixosConfiguration { inherit hostName hostModule system userModules inputs; }))
      (attrsToList hostModules));
in {
  inherit
    mkUserModules
    mkHostModules
    mkHomeConfigurations
    mkNixosConfigurations
    ;
}