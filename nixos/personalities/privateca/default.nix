{
    security.pki.certificates = [
        (builtins.readFile ./root_ca.crt)
    ];
}