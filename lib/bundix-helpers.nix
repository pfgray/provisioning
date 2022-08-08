let 

  hostnameAndPathFromURL = url:
    builtins.elemAt (
      builtins.trace "Checking url ${url}" (builtins.match "https?://(.*)" url) # [ "packages.shopify.io/foo" ]
    ) 0; # "packages.shopify.io/foo"

  lookUpAuthToken = var: # String -> String
    builtins.elemAt (
      builtins.match ".*https?://(.*)${builtins.trace "Reading var: ${var}" var}\n.*" (
        builtins.readFile ((builtins.getEnv "HOME") + "/.config/gem/gemrc")
      )
    ) 0;

  injectAuth = url: # String -> String
    let
      hostname = hostnameAndPathFromURL url;
      token = lookUpAuthToken hostname;
    in
      builtins.replaceStrings ["://"] ["://${token}"] url;
in {
  inherit injectAuth;
}