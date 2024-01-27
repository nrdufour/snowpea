{
    security.pki.certificates = [
        (builtins.readFile ./private-ca.crt)
    ];
}