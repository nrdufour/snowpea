{
  ## Defaulting to the local step-ca server (mysecrets.internal)

  security.acme = {
    acceptTerms = true;
    defaults = {
      webroot = "/var/lib/acme/acme-challenge";
      server = "https://mysecrets.internal:8443/acme/acme/directory";
      email = "nrdufour@gmail.com";
    };
  };
}