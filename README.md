# Generate-DockerImageVariants

[![github-actions](https://github.com/theohbrothers/Generate-DockerImageVariants/workflows/ci-master-pr/badge.svg)](https://github.com/theohbrothers/Generate-DockerImageVariants/actions)
[![github-release](https://img.shields.io/github/v/release/theohbrothers/Generate-DockerImageVariants?style=flat-square)](https://github.com/theohbrothers/Generate-DockerImageVariants/releases/)
[![powershell-gallery-release](https://img.shields.io/powershellgallery/v/Generate-DockerImageVariants?logo=powershell&logoColor=white&label=PSGallery&labelColor=&style=flat-square)](https://www.powershellgallery.com/packages/Generate-DockerImageVariants/)

Easily generate a repository populated with Docker image variants.

## Agenda

It is very common to need to have multiple variants of a docker image. This module solves this problem by creating a simple templating framework to generate a full repository containing:

- `Dockerfile` build contexts for variants
- Continuous integration (CI) configuration files to build and push variants' images to a docker registry, and the `README.md` containing the variants' image tags.

Here are some real repositories generated by using this module:

- https://github.com/theohbrothers/docker-alpine
- https://github.com/theohbrothers/docker-ansible
- https://github.com/theohbrothers/docker-certbot-dns-cron
- https://github.com/theohbrothers/docker-chrony
- https://github.com/theohbrothers/docker-easyrsa
- https://github.com/theohbrothers/docker-kubectl
- https://github.com/theohbrothers/docker-openvpn
- https://github.com/theohbrothers/docker-powershell
- https://github.com/theohbrothers/docker-php
- https://github.com/theohbrothers/docker-terraform
- https://github.com/theohbrothers/docker-varnish-agent
- https://github.com/theohbrothers/docker-webhook

## Install

Open [`powershell`](https://docs.microsoft.com/en-us/powershell/scripting/windows-powershell/install/installing-windows-powershell?view=powershell-5.1) or [`pwsh`](https://github.com/powershell/powershell#-powershell) and type:

```powershell
Install-Module -Name Generate-DockerImageVariants -Repository PSGallery -Scope CurrentUser -Verbose
```

If prompted to trust the repository, hit `Y` and `enter`.

## Usage

1. Initialize your repository.

    ```sh
    mkdir -p /path/to/my-project
    ```

2. Initialize the `/generate` folder

    ```powershell
    Import-Module Generate-DockerImageVariants
    cd /path/to/my-project
    Generate-DockerImageVariants . -Init
    ```

   Definition and template files are generated in the `/generate` folder.

    ```sh
    .
    ├── generate
    │   ├── definitions
    │   │   ├── FILES.ps1
    │   │   └── VARIANTS.ps1
    │   └── templates
    │       ├── Dockerfile.ps1
    │       └── README.md.ps1
    ```

3. Edit the definitions and template files in `/generate`:

4. Generate the variants:

    ```powershell
    cd /path/to/my-project
    Generate-DockerImageVariants .
    ```

   Build contexts of variants are generated in `/variants`.

   The repository tree now looks like:

    ```sh
    .
    ├── generate
    │   ├── definitions
    │   │   ├── FILES.ps1
    │   │   └── VARIANTS.ps1
    │   └── templates
    │       ├── Dockerfile.ps1
    │       └── README.md.ps1
    ├── README.md
    └── variants
        └── some-tag-of-variant
            └── Dockerfile
    ```

## Generation definitions and templates

A single folder named `/generate` at the base of the repository will hold all the definition and template files.

- `/generate/definitions` is the definitions folder containing two files `VARIANTS.ps1` and `FILES.ps1`
- `/generate/templates` is the templates folder and create template files. E.g. `/generate/templates/Dockerfile.ps1`, `/generate/templates/README.md.ps1`

```sh
.
├── generate
│   ├── definitions
│   │   ├── FILES.ps1       # An *optional* definition file for generation of repository files
│   │   └── VARIANTS.ps1    # Variant definition file for generation of variant build context
│   └── templates
│       ├── Dockerfile.ps1  # Dockerfile template (shared among variants across all distros)
│       └── README.md.ps1   # README.md template
```

## Generation of a variant

At minimum, the `/generate/definitions/VARIANTS.ps1` definition file should contain the `$VARIANTS` definition like this:

```powershell
$VARIANTS = @(
    @{
        tag = 'sometag'
        buildContextFiles = @{
            templates = @{
                'Dockerfile' = @{
                    common = $true
                    passes = @(
                        @{
                            variables = @{}
                        }
                    )
                }
            }
        }
    }
}
```

The `FILES.ps1` definition file is optional, but if used, at minimum it should look like:

```powershell
$FILES = @(
    # Paths are relative to the base of the project
    'README.md'
)
```

Upon generation, a file `/variants/sometag/Dockerfile` is generated in the `sometag` variant's build context in `/variants/sometag`, as well as a file `/README.md`, both relative to the base of the project.

```sh
.
├── README.md
└── variants
|   └── sometag
|       └── Dockerfile
```

See [this](docs/examples/basic) basic example.

## Generation of multiple variants

Suppose we want to generate two variants tagged `curl` and `git`:

```powershell
$VARIANTS = @(
    @{
        tag = 'curl'
    }
    @{
        tag = 'git'
    }
)

# This is a optional variable that sets a common buildContextFiles for all variants
# Individual variant buildContextsFiles takes precendence over this
$VARIANTS_SHARED = @{
    buildContextFiles = @{
        templates = @{
            'Dockerfile' = @{
                common = $true
                passes = @(
                    @{
                        variables = @{}
                    }
                )
            }
        }
    }
}
```

Upon generation, the `curl` and `git` variants' build contexts are generated:

```sh
.
└── variants
|   └── curl
|       └── Dockerfile
|   └── git
|       └── Dockerfile
```

See [this](docs/examples/basic-multiple-variants) example.

## Generation of a variant through file copying

Populating a build context might not always involve processing templates. Sometimes we simply want to copy a file into the build context.

To copy a file, simply use the property `copies` in `buildContextFiles`:

```powershell
$VARIANTS = @(
    @{
        tag = 'curl'
        buildContextFiles = @{
            copies = @(
                '/app'
            )
        }
    }
}
```

This will recursively copy all descending files/folders of the `/app` folder located relative to the *base* of the parent repository into the to-be-generated `curl` variant's build directory `/variants/curl` as `/variants/curl/app`.

See [this](docs/examples/basic-copies) example.

## Generation of a variant through multiple template passes

```powershell
$VARIANTS = @(
    @{
        tag = 'curl'
        buildContextFiles = @{
            templates = @{
                'Dockerfile' = @{
                    common = $false
                    passes = @(
                        # The first pass will generate 'Dockerfile'
                        @{
                            variables = @{
                                'foo' = 'bar'
                            }
                        }
                        # The second pass will generate 'Dockerfile.dev'
                        @{
                            variables = @{
                                'foo2' = 'bar2'
                            }
                            generatedFileNameOverride = 'Dockerfile.dev'
                        }
                    )
                }
            }
        }
    }
}
```

During generation, in addition to the `$VARIANT` object, a `$PASS_VARIABLES` hashtable will be in the scope of the processed `Dockerfile.ps1` template. In the first pass, the value of `$PASS_VARIABLES['foo']` will be `bar`, and the file `Dockerfile` will be generated in the variant's build context. In the second pass, the value of `$PASS_VARIABLES['foo2']` will be `bar2`, and the file `Dockerfile.dev` will be generated in the same build context.

See [this](docs/examples/basic-variables) example for using multiple passes with variables.

## Generation of a single variant's built context file(s) using Component-chaining

When a variant's `tag` contains words delimited by `-`, it is known as **Component-chaining**. The final generated file will be a concatanation of the product of processing the template of each component specified in this chain.

For instance, suppose you want a variant `Dockerfile` that installs `curl` and `git`:

```powershell
$VARIANTS = @(
    @{
        tag = 'curl-git'
        buildContextFiles = @{
            templates = @{
                'Dockerfile' = @{
                    common = $true
                    passes = @(
                        @{
                            variables = @{}
                        }
                    )
                }
            }
        }
    }
)
```

The template pass to generate the variant's build context `Dockerfile` proceeds as such:

1. The template `/generate/templates/Dockerfile.ps1` is processed

2. The file `/variants/curl-git/Dockerfile` is now generated in the `curl-git` variant's build context: `/variants/curl-git`

See [this](docs/examples/basic-component-chaining) example.

## Generation of multiple variants' built context file(s) using Component-chaining

```powershell
$VARIANTS = @(
    @{
        tag = 'curl-git'
    }
    @{
        tag = 'curl'
    }
    @{
        tag = 'git'
    }
}

# This is a special optional variable that sets a common buildContextFiles definition for all variants
$VARIANTS_SHARED = @{
    buildContextFiles = @{
        templates = @{
            'Dockerfile' = @{
                common = $false
                passes = @(
                    @{
                        variables = @{}
                    }
                )
            }
        }
    }
}
```

Upon generation, **three** variants build contexts for variants `curl-git`, `curl`, and `git` are generated:

```sh
.
└── variants
|   └── curl-git
|       └── Dockerfile
|   └── curl
|       └── Dockerfile
|   └── git
|       └── Dockerfile
```

See [this](docs/examples/basic-component-chaining) example.

To specify that only certain components be processed, independent of the `tag` property, ensure to define the `components` property. See these examples:

- [`/docs/examples/basic-custom-components`](docs/examples/basic-custom-components) example.
- [`/docs/examples/basic-custom-components-distro`](docs/examples/basic-custom-components-distro) example.

**Note: If the variant's `tag` consist of a word that matches the variant's `distro`, `distro` will not be among the `components`.** For instance, in the above example, if the `tag` is `curl-git-alpine`, there will still only be two components `curl` and `git`. `alpine` will not be considered a component.

## Optional: Generate other repository files

To generate files other than variant build contexts in `/variants`, define them in `FILES.ps1`.

Suppose we want to generate `README.md`:

```powershell
$FILES = @(
    'README.md'
)
```

Then, create their templates in the `/generate/templates` directory:

```sh
.
├── generate
│   └── templates
│       └── README.md.ps1       # README.md template
```

Upon generation, `README.md` is now generated:

```sh
.
└── .README.md
```

The variables `$VARIANTS` will be available during the processing of the template files.

See [this](docs/examples/basic-copies) example.

## Appendix

### Variant object properties

A `$VARIANT` definition will contain these properties.

The `buildContextFiles` property of the `$VARIANT` object can be used to customize the template processing:

- `common` - (Optional, defaults to `$false`) Specifies whether this file is shared by all distros. If value is `$true`, template has to be present in `/generate/templates/<file>.ps1`. If value is `$false`, and if a variant `distro` is defined, template has to be present in `/generate/templates/<file>/<distro>/`, or if a variant `distro` is omitted, template has to be present in `/generate/templates/<file>/<file>.ps1`.
- `includeHeader` - (Optional, defaults to `$false`) Specifies to process a template `<file>.header.ps1`. Template path determined by `common`
- `includeFooter` - (Optional, defaults to `$false`) Specifies to process a template `<file>.footer.ps1`. Template path determined by `common`
- `passes` - (Mandatory) An array of pass definitions that the template will undergo. Each pass will generate a single file.

Each template pass processes a template file `<file>.ps1` template and generates a single file named `<file>` in the variant's build context.

A pass can be configured with the `variables` and `generatedFileNameOverride` properties.

```powershell
$VARIANT = @{
    # Specifies the docker image tag
    # When the tag contains words delimited by '-', it known as component-chaining.
    tag = 'some-cool-tag'

    # Specifies a distro (optional). If you dont define a distro, templates will be sourced from /generate/templates/<file> folder
    # In contrast, if a distro is specified, templates will be sourced from /generate/templates/<file>/<distro> folder
    distro = 'somedistro'

    # Specifies that this variant should be tagged ':latest'. This property will be useful in generation of content in README.md or ci files. Automatically populated as $false if unspecified
    tag_as_latest = $false

    # Automatically populated
    tag_without_distro = 'somecomponent1-somecomponent2'

    # Specifies an list of components, independent of the `tag` property
    # If unspecified, this is automatically populated based on the components in the tag
    # If specified, the components override those specified in the tag
    components = @(
        'somecomponent1'
        'somecomponent2'
    )

    # Automatically populated
    build_dir_rel = './variants/distro/<tag_without_distro>'

    # Automatically populated
    build_dir = '/full/path/to/variants/distro/<tag_without_distro>'

    # Build context template definition
    buildContextFiles = @{
        templates = @{
            'Dockerfile' = @{
                # Specifies whether the template is common (shared) across distros
                common = $false

                # Specifies whether the template <file>.header.ps1 will be processed. Useful for Dockerfiles
                includeHeader = $true

                # Specifies whether the template <file>.footer.ps1 will be processed. Useful for Dockerfiles
                includeFooter = $true

                # Specifies a list of passes the template will be undergo, where each pass generates a file
                passes = @(
                    # This first pass generates the file called 'Dockerfile'
                    @{
                        # These variables will be available in $PASS_VARIABLES hashtable when this template is processed
                        variables = @{
                            foo = 'bar'
                        }

                        # If this is uncommented, the pass will generate the file named 'Dockerfile.dev' instead
                        # generatedFileNameOverride = 'Dockerfile.dev'
                    }
                )
            }
        }
        # Specifies the paths, relative to the root of the repository, to recursively copy into each variant's build context
        copies = @(
            '/app'
        )
    }
}
```

### Debugging

Use the `-Verbose` switch. This gives a detail trace of:

- Validation of `$VARIANTS` definition
- Validation of `$FILES` definition
- Template files or to-be-copied repository files for the build context generation
- Template files for repository files generation

This is particularly useful when the module is throwing errors about definitions, or about missing template or to-be-copied files.

#### Validation of `$VARIANTS` and `$FILES` definitions

For instance, if a variant was defined with an incorrect type (expected to be `hashtable`):

```powershell
$VARIANTS = @(
    1
    @{
        tag = 'curl'
        distro = 'alpine'
    }
}
```

Example of a validation trace:

```powershell
PS > cd /path/to/my-repo
PS > Generate-DockerImageVariants . -Verbose
VERBOSE: Validating $VARIANTS definition
VERBOSE: Validating TargetObject '1 System.Collections.Hashtable System.Collections.Hashtable System.Collections.Hashtable System.Collections.Hashtable System.Collections.Hashtable System.Collections.Hashtable' of type 'Object[]' and basetype 'array'       against Prototype 'System.Collections.Hashtable' of type 'Object[]' and basetype 'array'
VERBOSE:        Validating TargetObject '1' of type 'Int32' and basetype 'System.ValueType'             against Prototype 'System.Collections.Hashtable' of type 'Hashtable' and basetype 'System.Object'
WARNING: Failed with errors. Exception: Type System.Int32 is invalid! It should be of type 'System.Collections.Hashtable'.
```

This demonstrates that a variant definition has to be of type `hashtable`. The value `1` is of type `int32`, and hence is invalid.

#### Validation of template files or to-be-copied files

Example of a validation trace:

```powershell
PS > cd /path/to/my-repo
PS > Generate-DockerImageVariants . -Init
PS > Generate-DockerImageVariants . -Verbose
VERBOSE: Validating $VARIANTS definition
...
VERBOSE: Validating $FILES definition
...
Generating build context of variant 'curl': /path/to/my-repo/variants/curl
VERBOSE: Generating build context file: /path/to/my-repo/variants/curl/Dockerfile
VERBOSE: Processing template file: /path/to/my-repo/generate/templates/Dockerfile.ps1
Generating build context of variant 'curl-git': /path/to/my-repo/variants/curl-git
VERBOSE: Generating build context file: /path/to/my-repo/variants/curl-git/Dockerfile
VERBOSE: Processing template file: /path/to/my-repo/generate/templates/Dockerfile.ps1
Generating build context of variant 'my-cool-variant': /path/to/my-repo/variants/my-cool-variant
VERBOSE: Generating build context file: /path/to/my-repo/variants/my-cool-variant/Dockerfile
VERBOSE: Processing template file: /path/to/my-repo/generate/templates/Dockerfile.ps1
Generating repository file: /path/to/my-repo/README.md
VERBOSE: Processing template file: /path/to/my-repo/generate/templates/README.md.ps1
```
