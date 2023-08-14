To create install.yaml I just did:

* `wget https://github.com/argoproj/argo-cd/raw/v2.7.1/manifests/install.yaml`
* Modified install.yaml (added --insecure to server args)

To replicate the bug:

1. Run `./startup.sh` (you'll need k3d)
1. Create the Application in ArgoCD
    ```shell
    kubectl create ns bugtest
    kubectl apply -f argoproj.io-v1alpha1.Application-argocd-bugtest.yaml -n argocd
    ```
1. Sync will fail and will not retry (I've intentionally set up the readinessProbe so that it never succeeds and reduced the `progressDeadlineSeconds` to 20). The resources created in the PreSync hook are still there as we expect.
1. Sync again manually ensuring you UNTICK the RETRY tickbox

You can do this a bunch of times and the sync will continue to fail and the PreSync hook resources will continue to be there.

1. Now sync again manually but leave the RETRY tickbox TICKED and set the retry limit to 1.
1. The sync will fail, then retry, then fail, but this time the resources created in the PreSync hook get deleted!
