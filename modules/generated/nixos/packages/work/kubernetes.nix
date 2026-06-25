{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Required
    kubectl # talk to the cluster
    kubelogin-oidc # OIDC auth helper (int128/kubelogin); provides `kubectl oidc-login` plugin
    sops # encrypt secrets
    age # encryption keys for sops

    # Optional
    kubie # shell-isolated cluster/namespace switching
    kubeconform # validate manifests offline
    kustomize # build manifests
  ];
}
