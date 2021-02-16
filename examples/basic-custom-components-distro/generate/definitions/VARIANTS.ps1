# Docker image variants' definitions
$VARIANTS = @(
    @{
        # Specifies the docker image tag
        tag = 'foo-curl-bar-alpine'
        # Specifies a distro (optional). If you dont define a distro, you assume all your variants use the same distro.
        # In contrast, if a distro is specified, variants will be generated in their respective distro folder, in this case, '/variants/alpine'
        distro = 'alpine'
        # Specifies an list of components to process. If undefined, the components will be determined from the tag.
        # If unspecified, this is automatically populated
        components = @( 'curl' )
    }

    @{
        # Specifies the docker image tag
        tag = 'foo-curl-bar-ubuntu'
        # Specifies a distro (optional). If you dont define a distro, you assume all your variants use the same distro.
        # In contrast, if a distro is specified, variants will be generated in their respective distro folder, in this case, '/variants/alpine'
        distro = 'ubuntu'
        components = @( 'curl' )
    }
)

# This is a special global that sets a common buildContextFiles definition for all variants
# Docker image variants' definitions (shared)
$VARIANTS_SHARED = @{
    buildContextFiles = @{
        templates = @{
            # The path of the template to process, relative to the templates directory, omitting the '.ps1' extension
            'Dockerfile' = @{
                # Specifies whether the template is common (shared) across distros
                common = $false
                # Specifies whether the template <file>.header.ps1 will be processed. Useful for Dockerfiles
                includeHeader = $false
                # Specifies whether the template <file>.footer.ps1 will be processed. Useful for Dockerfiles
                includeFooter = $false
                # Specifies a list of passes the template will be undergo, where each pass generates a file
                passes = @(
                    @{
                        # These variables will be available in $PASS_VARIABLES hashtable when this template is processed
                        variables = @{}
                    }
                )
            }
        }
    }
}
