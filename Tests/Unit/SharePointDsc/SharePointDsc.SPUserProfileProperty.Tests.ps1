[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "")]
param(
    [Parameter()]
    [string]
    $SharePointCmdletModule = (Join-Path -Path $PSScriptRoot `
            -ChildPath "..\Stubs\SharePoint\15.0.4805.1000\Microsoft.SharePoint.PowerShell.psm1" `
            -Resolve)
)

Import-Module -Name (Join-Path -Path $PSScriptRoot `
        -ChildPath "..\UnitTestHelper.psm1" `
        -Resolve)

$Global:SPDscHelper = New-SPDscUnitTestHelper -SharePointStubModule $SharePointCmdletModule `
    -DscResource "SPUserProfileProperty"

Describe -Name $Global:SPDscHelper.DescribeHeader -Fixture {

    InModuleScope -ModuleName $Global:SPDscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:SPDscHelper.InitializeScript -NoNewScope

        $mockPassword = ConvertTo-SecureString -String "password" -AsPlainText -Force
        $farmAccount = New-Object -TypeName "System.Management.Automation.PSCredential" `
            -ArgumentList @("username", $mockPassword)

        $testParamsNewProperty = @{
            Name                = "WorkEmailNew"
            UserProfileService  = "User Profile Service Application"
            DisplayName         = "WorkEmailNew"
            Type                = "String (Single Value)"
            Description         = ""
            PolicySetting       = "Mandatory"
            PrivacySetting      = "Public"
            PropertyMappings    = @(
                (New-CimInstance -ClassName MSFT_SPUserProfilePropertyMapping -ClientOnly -Property @{
                        ConnectionName = "contoso"
                        PropertyName   = "department"
                        Direction      = "Import"
                    })
            )
            Length              = 30
            DisplayOrder        = 5496
            IsEventLog          = $false
            IsVisibleOnEditor   = $true
            IsVisibleOnViewer   = $true
            IsUserEditable      = $true
            IsAlias             = $false
            IsSearchable        = $false
            TermStore           = "Managed Metadata service"
            TermGroup           = "People"
            TermSet             = "Department"
            UserOverridePrivacy = $false
        }

        $testParamsUpdateProperty = @{
            Name                = "WorkEmailUpdate"
            UserProfileService  = "User Profile Service Application"
            DisplayName         = "WorkEmailUpdate"
            Type                = "String (Single Value)"
            Description         = ""
            PolicySetting       = "Optin"
            PrivacySetting      = "Private"
            Ensure              = "Present"
            PropertyMappings    = @(
                (New-CimInstance -ClassName MSFT_SPUserProfilePropertyMapping -ClientOnly -Property @{
                        ConnectionName = "contoso"
                        PropertyName   = "department"
                        Direction      = "Import"
                    })
            )
            Length              = 25
            DisplayOrder        = 5401
            IsEventLog          = $true
            IsVisibleOnEditor   = $True
            IsVisibleOnViewer   = $true
            IsUserEditable      = $true
            IsAlias             = $true
            IsSearchable        = $true
            TermStore           = "Managed Metadata service"
            TermGroup           = "People"
            TermSet             = "Location"
            UserOverridePrivacy = $false
        }

        try
        {
            [Microsoft.Office.Server.UserProfiles]
        }
        catch
        {
            Add-Type @"
                namespace Microsoft.Office.Server.UserProfiles {
                    public enum ConnectionType {
                        ActiveDirectory,
                        BusinessDataCatalog
                    };
                    public enum ProfileType {
                        User
                    };
                }
"@ -ErrorAction SilentlyContinue
        }

        $corePropertyUpdate = @{
            DisplayName   = "WorkEmailUpdate"
            Name          = "WorkEmailUpdate"
            IsMultiValued = $false
            Type          = "String (Single Value)"
            TermSet       = @{
                Name      = $testParamsUpdateProperty.TermSet
                Group     = @{
                    Name = $testParamsUpdateProperty.TermGroup
                }
                TermStore = @{
                    Name = $testParamsUpdateProperty.TermStore
                }
            }
            Length        = 25
            IsSearchable  = $true
        } | Add-Member ScriptMethod Commit {
            $Global:SPUPSPropertyCommitCalled = $true
        } -PassThru -Force | Add-Member ScriptMethod Delete {
            $Global:SPUPSPropertyDeleteCalled = $true
        } -PassThru -Force

        $corePropertyUpdate.Type = $corePropertyUpdate.Type | Add-Member ScriptMethod GetTypeCode {
            $Global:SPUPSPropertyGetTypeCodeCalled = $true
            return $corePropertyUpdate.Type
        } -PassThru -Force

        $coreProperties = @{
            WorkEmailUpdate = $corePropertyUpdate
        }

        $coreProperties = $coreProperties | Add-Member ScriptMethod Create {
            $Global:SPUPCoreCreateCalled = $true
            return @{
                Name        = ""
                DisplayName = ""
                Type        = ""
                TermSet     = $null
                Length      = 10
            }
        } -PassThru | Add-Member ScriptMethod RemovePropertyByName {
            $Global:SPUPCoreRemovePropertyByNameCalled = $true
        } -PassThru | Add-Member ScriptMethod Add {
            $Global:SPUPCoreAddCalled = $true
        } -PassThru -Force

        $typePropertyUpdate = @{
            IsVisibleOnViewer = $true
            IsVisibleOnEditor = $true
            IsEventLog        = $true
        } | Add-Member ScriptMethod Commit {
            $Global:SPUPPropertyCommitCalled = $true
        } -PassThru

        $subTypePropertyUpdate = @{
            Name                = "WorkEmailUpdate"
            DisplayName         = "WorkEmailUpdate"
            Description         = ""
            PrivacyPolicy       = "Optin"
            DefaultPrivacy      = "Private"
            DisplayOrder        = 5401
            IsUserEditable      = $true
            IsAlias             = $true
            CoreProperty        = $corePropertyUpdate
            TypeProperty        = $typePropertyUpdate
            UserOverridePrivacy = $false
        } | Add-Member ScriptMethod Commit {
            $Global:SPUPPropertyCommitCalled = $true
        } -PassThru

        $coreProperty = @{
            DisplayName   = $testParamsNewProperty.DisplayName
            Name          = $testParamsNewProperty.Name
            IsMultiValued = $testParamsNewProperty.Type -eq "String (Multi Value)"
            Type          = $testParamsNewProperty.Type
            TermSet       = @{
                Name      = $testParamsNewProperty.TermSet
                Group     = @{
                    Name = $testParamsNewProperty.TermGroup
                }
                TermStore = @{
                    Name = $testParamsNewProperty.TermStore
                }
            }
            Length        = $testParamsNewProperty.Length
            IsSearchable  = $testParamsNewProperty.IsSearchable
        } | Add-Member ScriptMethod Commit {
            $Global:SPUPSPropertyCommitCalled = $true
        } -PassThru | Add-Member ScriptMethod Delete {
            $Global:SPUPSPropertyDeleteCalled = $true
        } -PassThru

        $typeProperty = @{
            IsVisibleOnViewer = $testParamsNewProperty.IsVisibleOnViewer
            IsVisibleOnEditor = $testParamsNewProperty.IsVisibleOnEditor
            IsEventLog        = $testParamsNewProperty.IsEventLog
        } | Add-Member ScriptMethod Commit {
            $Global:SPUPPropertyCommitCalled = $true
        } -PassThru

        $subTypeProperty = @{
            Name                = $testParamsNewProperty.Name
            DisplayName         = $testParamsNewProperty.DisplayName
            Description         = $testParamsNewProperty.Description
            PrivacyPolicy       = $testParamsNewProperty.PolicySetting
            DefaultPrivacy      = $testParamsNewProperty.PrivacySetting
            DisplayOrder        = $testParamsNewProperty.DisplayOrder
            IsUserEditable      = $testParamsNewProperty.IsUserEditable
            IsAlias             = $testParamsNewProperty.IsAlias
            CoreProperty        = $coreProperty
            TypeProperty        = $typeProperty
            AllowPolicyOverride = $true
        } | Add-Member ScriptMethod Commit {
            $Global:SPUPPropertyCommitCalled = $true
        } -PassThru

        $userProfileSubTypePropertiesNoProperty = @{
        } | Add-Member ScriptMethod Create {
            $Global:SPUPSubTypeCreateCalled = $true
        } -PassThru | Add-Member ScriptMethod GetPropertyByName {
            $result = $null
            if ($Global:SPUPGetPropertyByNameCalled -eq $true)
            {
                $result = $subTypeProperty
            }
            $Global:SPUPGetPropertyByNameCalled = $true
            return $result
        } -PassThru | Add-Member ScriptMethod Add {
            $Global:SPUPSubTypeAddCalled = $true
        } -PassThru -Force

        $userProfileSubTypePropertiesUpdateProperty = @{
            "WorkEmailUpdate" = $subTypePropertyUpdate
        } | Add-Member ScriptMethod Create {
            $Global:SPUPSubTypeCreateCalled = $true
        } -PassThru | Add-Member ScriptMethod Add {
            $Global:SPUPSubTypeAddCalled = $true
        } -PassThru -Force | Add-Member ScriptMethod GetPropertyByName {
            $Global:SPUPGetPropertyByNameCalled = $true
            return $subTypePropertyUpdate
        } -PassThru


        Mock -CommandName Get-SPDscUserProfileSubTypeManager -MockWith {
            $result = @{
            } | Add-Member ScriptMethod GetProfileSubtype {
                $Global:SPUPGetProfileSubtypeCalled = $true
                return @{
                    Properties = $userProfileSubTypePropertiesNoProperty
                }
            } -PassThru

            return $result
        }

        Mock -CommandName Get-SPWebApplication -MockWith {
            return @(
                @{
                    IsAdministrationWebApplication = $true
                    Url                            = "caURL"
                }
            )
        }
        #IncludeCentralAdministration
        $TermSets = @{
            Department = @{
                Name = "Department"
            }
            Location   = @{
                Name = "Location"
            }
        }

        $TermGroups = @{
            People = @{
                Name     = "People"
                TermSets = $TermSets
            }
        }

        $TermStoresList = @{
            "Managed Metadata service" = @{
                Name   = "Managed Metadata service"
                Groups = $TermGroups
            }
        }


        Mock -CommandName New-Object -MockWith {
            return (@{
                    TermStores = $TermStoresList
                })
        } -ParameterFilter {
            $TypeName -eq "Microsoft.SharePoint.Taxonomy.TaxonomySession" }

        Mock -CommandName New-Object -MockWith {
            return (@{
                    Properties = @{

                    } | Add-Member ScriptMethod SetDisplayOrderByPropertyName {
                        $Global:UpsSetDisplayOrderByPropertyNameCalled = $true
                        return $false
                    } -PassThru | Add-Member ScriptMethod CommitDisplayOrder {
                        $Global:UpsSetDisplayOrderByPropertyNameCalled = $true
                        return $false
                    } -PassThru
                })
        } -ParameterFilter {
            $TypeName -eq "Microsoft.Office.Server.UserProfiles.UserProfileManager" }
        Mock Invoke-SPDscCommand {
            return Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList $Arguments -NoNewScope
        }


        $propertyMappingItem = @{
            DataSourcePropertyName = "mail"
            IsImport               = $true
            IsExport               = $false
        } | Add-Member ScriptMethod Delete {
            $Global:UpsMappingDeleteCalled = $true
            return $true
        } -PassThru

        $propertyMapping = @{ } | Add-Member ScriptMethod Item {
            param(
                [string]
                $property
            )
            $Global:SPUPSMappingItemCalled = $true
            if ($property -eq "WorkEmailUpdate")
            {
                return $propertyMappingItem
            }
        } -PassThru -Force | Add-Member ScriptMethod AddNewExportMapping {
            $Global:UpsMappingAddNewExportCalled = $true
            return $true
        } -PassThru -Force | Add-Member ScriptMethod AddNewMapping {
            $Global:UpsMappingAddNewMappingCalled = $true
            return $true
        } -PassThru -Force

        $connection = @{
            DisplayName     = "Contoso"
            Server          = "contoso.com"
            AccountDomain   = "Contoso"
            AccountUsername = "TestAccount"
            Type            = "ActiveDirectory"
            PropertyMapping = $propertyMapping
        }

        $connection = $connection | Add-Member ScriptMethod Update {
            $Global:SPUPSSyncConnectionUpdateCalled = $true
        } -PassThru | Add-Member ScriptMethod AddPropertyMapping {
            $Global:SPUPSSyncConnectionAddPropertyMappingCalled = $true
        } -PassThru


        $ConnnectionManager = @{
            $($connection.DisplayName) = @($connection) | Add-Member ScriptMethod  AddActiveDirectoryConnection {
                param(
                    [Microsoft.Office.Server.UserProfiles.ConnectionType]
                    $connectionType,
                    $name,
                    $forest,
                    $useSSL,
                    $userName,
                    $pwd,
                    $namingContext,
                    $p1,
                    $p2
                )
                $Global:SPUPSAddActiveDirectoryConnectionCalled = $true
            } -PassThru
        }

        Mock -CommandName New-Object -MockWith {
            $ProfilePropertyManager = @{
                "Contoso" = $connection
            } | Add-Member ScriptMethod GetCoreProperties {
                $Global:UpsConfigManagerGetCorePropertiesCalled = $true
                return ($coreProperties)
            } -PassThru | Add-Member ScriptMethod GetProfileTypeProperties {
                $Global:UpsConfigManagerGetProfileTypePropertiesCalled = $true
                return $userProfileSubTypePropertiesUpdateProperty
            } -PassThru
            return (@{
                    ProfilePropertyManager = $ProfilePropertyManager
                    ConnectionManager      = $ConnnectionManager
                } | Add-Member ScriptMethod IsSynchronizationRunning {
                    $Global:UpsSyncIsSynchronizationRunning = $true
                    return $false
                } -PassThru   )
        } -ParameterFilter {
            $TypeName -eq "Microsoft.Office.Server.UserProfiles.UserProfileConfigManager" }

        $userProfileServiceValidConnection = @{
            Name                         = "User Profile Service Application"
            TypeName                     = "User Profile Service Application"
            ApplicationPool              = "SharePoint Service Applications"
            FarmAccount                  = $farmAccount
            ServiceApplicationProxyGroup = "Proxy Group"
            ConnectionManager            = @($connection)
        }

        Context -Name "Non-Existing User Profile Service Application" {
            Mock -CommandName Get-SPServiceApplication { return $null }
            It "Should return Ensure = Absent" {
                $Global:SPUPGetProfileSubtypeCalled = $false
                $Global:SPUPGetPropertyByNameCalled = $false
                $Global:SPUPSMappingItemCalled = $false
                (Get-TargetResource @testParamsNewProperty).Ensure | Should Be "Absent"
            }
        }

        Mock -CommandName Get-SPServiceApplication { return $userProfileServiceValidConnection }

        Context -Name "When property doesn't exist" {

            It "Should return null from the Get method" {
                $Global:SPUPGetProfileSubtypeCalled = $false
                $Global:SPUPGetPropertyByNameCalled = $false
                $Global:SPUPSMappingItemCalled = $false
                (Get-TargetResource @testParamsNewProperty).Ensure | Should Be "Absent"
                Assert-MockCalled Get-SPServiceApplication -ParameterFilter { $Name -eq $testParamsNewProperty.UserProfileService }
                $Global:SPUPGetProfileSubtypeCalled | Should be $true
                $Global:SPUPGetPropertyByNameCalled | Should be $true
                $Global:SPUPSMappingItemCalled | Should be $false
            }

            It "Should return false when the Test method is called" {
                $Global:SPUPGetPropertyByNameCalled = $false
                Test-TargetResource @testParamsNewProperty | Should Be $false
                $Global:SPUPGetPropertyByNameCalled | Should be $true
            }

            It "creates a new user profile property in the set method" {
                $Global:SPUPGetProfileSubtypeCalled = $false

                $Global:SPUPSMappingItemCalled = $false
                Set-TargetResource @testParamsNewProperty
                $Global:SPUPGetProfileSubtypeCalled | Should be $true

                $Global:SPUPSMappingItemCalled | Should be $true

            }

        }

        Context -Name "When property doesn't exist, connection doesn't exist" {
            Mock -CommandName New-Object -MockWith {
                $ProfilePropertyManager = @{"Contoso" = $connection } | Add-Member ScriptMethod GetCoreProperties {
                    $Global:UpsConfigManagerGetCorePropertiesCalled = $true
                    return ($coreProperties)
                } -PassThru | Add-Member ScriptMethod GetProfileTypeProperties {
                    $Global:UpsConfigManagerGetProfileTypePropertiesCalled = $true
                    return $userProfileSubTypePropertiesUpdateProperty
                } -PassThru
                return (@{
                        ProfilePropertyManager = $ProfilePropertyManager
                        ConnectionManager      = @{ }
                    } | Add-Member ScriptMethod IsSynchronizationRunning {
                        $Global:UpsSyncIsSynchronizationRunning = $true
                        return $false
                    } -PassThru   )
            } -ParameterFilter { $TypeName -eq "Microsoft.Office.Server.UserProfiles.UserProfileConfigManager" }

            It "Should return null from the Get method" {
                $Global:SPUPGetProfileSubtypeCalled = $false
                $Global:SPUPGetPropertyByNameCalled = $false
                $Global:SPUPSMappingItemCalled = $false
                (Get-TargetResource @testParamsNewProperty).Ensure | Should Be "Absent"
                Assert-MockCalled Get-SPServiceApplication -ParameterFilter { $Name -eq $testParamsNewProperty.UserProfileService }
                $Global:SPUPGetProfileSubtypeCalled | Should be $true
                $Global:SPUPGetPropertyByNameCalled | Should be $true
                $Global:SPUPSMappingItemCalled | Should be $false
            }

            It "Should return false when the Test method is called" {
                $Global:SPUPGetPropertyByNameCalled = $false
                Test-TargetResource @testParamsNewProperty | Should Be $false
                $Global:SPUPGetPropertyByNameCalled | Should be $true
            }

            It "attempts to create a new property but fails as connection isn't available" {
                $Global:SPUPGetProfileSubtypeCalled = $false
                $Global:SPUPGetPropertyByNameCalled = $false
                $Global:SPUPSMappingItemCalled = $false

                { Set-TargetResource @testParamsNewProperty } | should throw "connection not found"

                $Global:SPUPGetProfileSubtypeCalled | Should be $true
                $Global:SPUPGetPropertyByNameCalled | Should be $true
                $Global:SPUPSMappingItemCalled | Should be $false

            }
        }

        Context -Name "When property doesn't exist, term set doesn't exist" {
            $termSet = $testParamsNewProperty.TermSet
            $testParamsNewProperty.TermSet = "Invalid"

            It "Should return null from the Get method" {
                $Global:SPUPGetPropertyByNameCalled = $false
                $Global:SPUPGetPropertyByNameCalled = $false
                $Global:SPUPSMappingItemCalled = $false
                (Get-TargetResource @testParamsNewProperty).Ensure | Should Be "Absent"
                Assert-MockCalled Get-SPServiceApplication -ParameterFilter { $Name -eq $testParamsNewProperty.UserProfileService }
                $Global:SPUPGetProfileSubtypeCalled | Should be $true
                $Global:SPUPGetPropertyByNameCalled | Should be $true
                $Global:SPUPSMappingItemCalled | Should be $false
            }

            It "Should return false when the Test method is called" {
                $Global:SPUPGetPropertyByNameCalled = $false
                Test-TargetResource @testParamsNewProperty | Should Be $false
                $Global:SPUPGetPropertyByNameCalled | Should be $true
            }

            It "creates a new user profile property in the set method" {
                $Global:SPUPGetProfileSubtypeCalled = $false
                $Global:SPUPSMappingItemCalled = $false

                { Set-TargetResource @testParamsNewProperty } | should throw "Term Set $($testParamsNewProperty.TermSet) not found"

                $Global:SPUPGetProfileSubtypeCalled | Should be $true
                $Global:SPUPSMappingItemCalled | Should be $false

            }
            $testParamsNewProperty.TermSet = $termSet
        }

        Context -Name "When required values are not all passed" {
            $testParamsNewProperty.TermGroup = $null
            It "Should throw error from Set method" {
                { Set-TargetResource @testParamsNewProperty } | Should throw "Term Group  not found"
            }
        }

        Context -Name "When ConfigurationManager is null" {
            Mock -CommandName New-Object -MockWith {
                $ProfilePropertyManager = @{"Contoso" = $connection } | Add-Member ScriptMethod GetCoreProperties {
                    $Global:UpsConfigManagerGetCorePropertiesCalled = $true
                    return ($coreProperties)
                } -PassThru | Add-Member ScriptMethod GetProfileTypeProperties {
                    $Global:UpsConfigManagerGetProfileTypePropertiesCalled = $true
                    return $userProfileSubTypePropertiesUpdateProperty
                } -PassThru
                return (
                    @{
                        ProfilePropertyManager = $ProfilePropertyManager
                        ConnectionManager      = $null
                    } | Add-Member ScriptMethod IsSynchronizationRunning {
                        $Global:UpsSyncIsSynchronizationRunning = $true
                        return $false
                    } -PassThru
                )
            } -ParameterFilter { $TypeName -eq "Microsoft.Office.Server.UserProfiles.UserProfileConfigManager" }

            It "Should return Ensure = Absent from the Get method" {
                (Get-TargetResource @testParamsNewProperty).Ensure | Should Be "Absent"
            }
        }

        Context -Name "When Sync Connection is set to Export" {
            Mock -CommandName New-Object -MockWith {
                $ProfilePropertyManager = @{"Contoso" = $connection } | Add-Member ScriptMethod GetCoreProperties {
                    $Global:UpsConfigManagerGetCorePropertiesCalled = $true
                    return ($coreProperties)
                } -PassThru | Add-Member ScriptMethod GetProfileTypeProperties {
                    $Global:UpsConfigManagerGetProfileTypePropertiesCalled = $true
                    return $userProfileSubTypePropertiesUpdateProperty
                } -PassThru
                return (@{
                        ProfilePropertyManager = $ProfilePropertyManager
                        ConnectionManager      = $null
                    } | Add-Member ScriptMethod IsSynchronizationRunning {
                        $Global:UpsSyncIsSynchronizationRunning = $true
                        return $false
                    } -PassThru   )
            } -ParameterFilter { $TypeName -eq "Microsoft.Office.Server.UserProfiles.UserProfileConfigManager" }

            It "Should return Ensure = Absent from the Get method" {
                (Get-TargetResource @testParamsNewProperty).Ensure | Should Be "Absent"
            }
        }

        Context -Name "When property doesn't exist, term group doesn't exist" {
            $termGroup = $testParamsNewProperty.TermGroup
            $testParamsNewProperty.TermGroup = "InvalidGroup"

            It "Should return null from the Get method" {
                $Global:SPUPGetPropertyByNameCalled = $false
                $Global:SPUPGetPropertyByNameCalled = $false
                $Global:SPUPSMappingItemCalled = $false
                (Get-TargetResource @testParamsNewProperty).Ensure | Should Be "Absent"
                Assert-MockCalled Get-SPServiceApplication -ParameterFilter { $Name -eq $testParamsNewProperty.UserProfileService }
                $Global:SPUPGetProfileSubtypeCalled | Should be $true
                $Global:SPUPGetPropertyByNameCalled | Should be $true
                $Global:SPUPSMappingItemCalled | Should be $false
            }

            It "Should return false when the Test method is called" {
                $Global:SPUPGetPropertyByNameCalled = $false
                Test-TargetResource @testParamsNewProperty | Should Be $false
                $Global:SPUPGetPropertyByNameCalled | Should be $true
            }

            It "creates a new user profile property in the set method" {
                $Global:SPUPGetProfileSubtypeCalled = $false
                $Global:SPUPSMappingItemCalled = $false

                { Set-TargetResource @testParamsNewProperty } | should throw "Term Group $($testParamsNewProperty.TermGroup) not found"

                $Global:SPUPGetProfileSubtypeCalled | Should be $true
                $Global:SPUPSMappingItemCalled | Should be $false

            }
            $testParamsNewProperty.TermGroup = $termGroup
        }

        Context -Name "When property doesn't exist, term store doesn't exist" {
            $termStore = $testParamsNewProperty.TermStore
            $testParamsNewProperty.TermStore = "InvalidStore"

            It "Should return null from the Get method" {
                $Global:SPUPGetPropertyByNameCalled = $false
                $Global:SPUPGetPropertyByNameCalled = $false
                $Global:SPUPSMappingItemCalled = $false
                (Get-TargetResource @testParamsNewProperty).Ensure | Should Be "Absent"
                Assert-MockCalled Get-SPServiceApplication -ParameterFilter { $Name -eq $testParamsNewProperty.UserProfileService }
                $Global:SPUPGetProfileSubtypeCalled | Should be $true
                $Global:SPUPGetPropertyByNameCalled | Should be $true
                $Global:SPUPSMappingItemCalled | Should be $false
            }

            It "Should return false when the Test method is called" {
                $Global:SPUPGetPropertyByNameCalled = $false
                Test-TargetResource @testParamsNewProperty | Should Be $false
                $Global:SPUPGetPropertyByNameCalled | Should be $true
            }

            It "creates a new user profile property in the set method" {
                $Global:SPUPGetProfileSubtypeCalled = $false
                $Global:SPUPSMappingItemCalled = $false

                { Set-TargetResource @testParamsNewProperty } | should throw "Term Store $($testParamsNewProperty.TermStore) not found"

                $Global:SPUPGetProfileSubtypeCalled | Should be $true
                $Global:SPUPSMappingItemCalled | Should be $false

            }
            $testParamsNewProperty.TermStore = $termStore
        }

        Context -Name "When property exists and all properties match" {
            Mock -CommandName Get-SPDscUserProfileSubTypeManager -MockWith {
                $result = @{ } | Add-Member ScriptMethod GetProfileSubtype {
                    $Global:SPUPGetProfileSubtypeCalled = $true
                    return @{
                        Properties = $userProfileSubTypePropertiesUpdateProperty
                    }
                } -PassThru

                return $result
            }

            It "Should return valid value from the Get method" {
                $Global:SPUPGetProfileSubtypeCalled = $false
                $Global:SPUPGetPropertyByNameCalled = $false
                $Global:SPUPSMappingItemCalled = $false
                (Get-TargetResource @testParamsNewProperty).Ensure | Should Be "Present"
                Assert-MockCalled Get-SPServiceApplication -ParameterFilter { $Name -eq $testParamsUpdateProperty.UserProfileService }
                $Global:SPUPGetProfileSubtypeCalled | Should be $true
                $Global:SPUPGetPropertyByNameCalled | Should be $true
                $Global:SPUPSMappingItemCalled | Should be $true
            }

            It "Should return false when the Test method is called" {
                $Global:SPUPGetPropertyByNameCalled = $false
                Test-TargetResource @testParamsUpdateProperty | Should Be $false
                $Global:SPUPGetPropertyByNameCalled | Should be $true
            }

            It "updates an user profile property in the set method" {
                $Global:SPUPGetProfileSubtypeCalled = $false
                $Global:SPUPSMappingItemCalled = $false
                Set-TargetResource @testParamsUpdateProperty
                $Global:SPUPGetProfileSubtypeCalled | Should be $true
                $Global:SPUPSMappingItemCalled | Should be $true
            }

            It "Should throw an error if the MappingDirection is set to Export" {
                $testParamsExport = $testParamsUpdateProperty
                $connection.Type = "ActiveDirectoryImport"
                $testParamsExport.PropertyMappings[0].Direction = "Export"
                $propertyMappingItem.IsImport = $true

                { Set-TargetResource @testParamsExport } | Should throw "not implemented"
                $connection.Type = "ActiveDirectory"
            }
        }

        Context -Name "When property exists and type is different - throws exception" {
            $currentType = $testParamsUpdateProperty.Type
            $testParamsUpdateProperty.Type = "String (Multi Value)"
            Mock -CommandName Get-SPDscUserProfileSubTypeManager -MockWith {
                $result = @{ } | Add-Member ScriptMethod GetProfileSubtype {
                    $Global:SPUPGetProfileSubtypeCalled = $true
                    return @{
                        Properties = $userProfileSubTypePropertiesUpdateProperty
                    }
                } -PassThru

                return $result
            }

            It "Should return valid value from the Get method" {
                $Global:SPUPGetProfileSubtypeCalled = $false
                $Global:SPUPGetPropertyByNameCalled = $false
                $Global:SPUPSMappingItemCalled = $false
                (Get-TargetResource @testParamsNewProperty).Ensure | Should Be "Present"
                Assert-MockCalled Get-SPServiceApplication -ParameterFilter { $Name -eq $testParamsUpdateProperty.UserProfileService }
                $Global:SPUPGetProfileSubtypeCalled | Should be $true
                $Global:SPUPGetPropertyByNameCalled | Should be $true
                $Global:SPUPSMappingItemCalled | Should be $true
            }

            It "Should return false when the Test method is called" {
                $Global:SPUPGetPropertyByNameCalled = $false
                Test-TargetResource @testParamsUpdateProperty | Should Be $false
                $Global:SPUPGetPropertyByNameCalled | Should be $true
            }

            It "attempts to update an user profile property in the set method" {
                $Global:SPUPGetProfileSubtypeCalled = $false
                $Global:SPUPGetPropertyByNameCalled = $false
                $Global:SPUPSMappingItemCalled = $false

                { Set-TargetResource @testParamsUpdateProperty } | should throw "Can't change property type. Current Type"

                $Global:SPUPGetProfileSubtypeCalled | Should be $true
                $Global:SPUPGetPropertyByNameCalled | Should be $true
                $Global:SPUPSMappingItemCalled | Should be $false
            }
            $testParamsUpdateProperty.Type = $currentType
        }

        Context -Name "When property exists and mapping exists, mapping config does not match" {

            #$propertyMappingItem.DataSourcePropertyName = "property"

            Mock -CommandName Get-SPDscUserProfileSubTypeManager -MockWith {
                $result = @{ } | Add-Member ScriptMethod GetProfileSubtype {
                    $Global:SPUPGetProfileSubtypeCalled = $true
                    return @{
                        Properties = $userProfileSubTypePropertiesUpdateProperty
                    }
                } -PassThru

                return $result
            }

            It "Should return valid value from the Get method" {
                $Global:SPUPGetProfileSubtypeCalled = $false
                $Global:SPUPGetPropertyByNameCalled = $false
                $Global:SPUPSMappingItemCalled = $false
                (Get-TargetResource @testParamsNewProperty).Ensure | Should Be "Present"
                Assert-MockCalled Get-SPServiceApplication -ParameterFilter { $Name -eq $testParamsUpdateProperty.UserProfileService }
                $Global:SPUPGetProfileSubtypeCalled | Should be $true
                $Global:SPUPGetPropertyByNameCalled | Should be $true
                $Global:SPUPSMappingItemCalled | Should be $true
            }

            It "Should return false when the Test method is called" {
                $Global:SPUPGetPropertyByNameCalled = $false
                Test-TargetResource @testParamsUpdateProperty | Should Be $false
                $Global:SPUPGetPropertyByNameCalled | Should be $true
            }

            It "updates an user profile property in the set method" {
                $Global:SPUPGetProfileSubtypeCalled = $false
                $Global:SPUPGetPropertyByNameCalled = $false
                $Global:SPUPSMappingItemCalled = $false

                Set-TargetResource @testParamsUpdateProperty

                $Global:SPUPGetProfileSubtypeCalled | Should be $true
                $Global:SPUPGetPropertyByNameCalled | Should be $true
                $Global:SPUPSMappingItemCalled | Should be $true
            }
        }

        Context -Name "When property exists and mapping does not exist" {
            $propertyMappingItem = $null
            Mock -CommandName Get-SPDscUserProfileSubTypeManager -MockWith {
                $result = @{ } | Add-Member ScriptMethod GetProfileSubtype {
                    $Global:SPUPGetProfileSubtypeCalled = $true
                    return @{
                        Properties = $userProfileSubTypePropertiesUpdateProperty
                    }
                } -PassThru

                return $result
            }

            It "Should return valid value from the Get method" {
                $Global:SPUPGetProfileSubtypeCalled = $false
                $Global:SPUPGetPropertyByNameCalled = $false
                $Global:SPUPSMappingItemCalled = $false
                (Get-TargetResource @testParamsNewProperty).Ensure | Should Be "Present"
                Assert-MockCalled Get-SPServiceApplication -ParameterFilter { $Name -eq $testParamsUpdateProperty.UserProfileService }
                $Global:SPUPGetProfileSubtypeCalled | Should be $true
                $Global:SPUPGetPropertyByNameCalled | Should be $true
                $Global:SPUPSMappingItemCalled | Should be $true
            }

            It "Should return false when the Test method is called" {
                $Global:SPUPGetPropertyByNameCalled = $false
                Test-TargetResource @testParamsUpdateProperty | Should Be $false
                $Global:SPUPGetPropertyByNameCalled | Should be $true
            }

            It "updates an user profile property in the set method" {
                $Global:SPUPGetProfileSubtypeCalled = $false
                $Global:SPUPGetPropertyByNameCalled = $false
                $Global:SPUPSMappingItemCalled = $false

                Set-TargetResource @testParamsUpdateProperty

                $Global:SPUPGetProfileSubtypeCalled | Should be $true
                $Global:SPUPGetPropertyByNameCalled | Should be $true
                $Global:SPUPSMappingItemCalled | Should be $true
            }
        }

        Context -Name "When property exists and ensure equals Absent" {
            Mock -CommandName Get-SPDscUserProfileSubTypeManager -MockWith {
                $result = @{ } | Add-Member ScriptMethod GetProfileSubtype {
                    $Global:SPUPGetProfileSubtypeCalled = $true
                    return @{
                        Properties = $userProfileSubTypePropertiesUpdateProperty
                    }
                } -PassThru

                return $result
            }

            $testParamsUpdateProperty.Ensure = "Absent"

            It "deletes an user profile property in the set method" {
                $Global:SPUPGetProfileSubtypeCalled = $false
                $Global:SPUPGetPropertyByNameCalled = $false
                $Global:SPUPSMappingItemCalled = $false
                $Global:SPUPCoreRemovePropertyByNameCalled = $false

                Set-TargetResource @testParamsUpdateProperty

                $Global:SPUPGetProfileSubtypeCalled | Should be $true
                $Global:SPUPGetPropertyByNameCalled | Should be $true
                $Global:SPUPSMappingItemCalled | Should be $false
                $Global:SPUPCoreRemovePropertyByNameCalled | Should be $true
            }
        }

        Context -Name "When a AD Import Connection should be configured" {

            # Mocks for AD Import Connection

            Mock -CommandName Get-SPDscUserProfileSubTypeManager -MockWith {
                $result = @{ } | Add-Member ScriptMethod GetProfileSubtype {
                    $Global:SPUPGetProfileSubtypeCalled = $true
                    return @{
                        Properties = $userProfileSubTypePropertiesUpdateProperty
                    }
                } -PassThru

                return $result
            }

            $propertyMapping = ([PSCustomObject]@{ }) | Add-Member ScriptMethod Item {
                param(
                    [string]
                    $property
                )
                $Global:SPUPSMappingItemCalled = $true
            } -PassThru -Force | Add-Member ScriptMethod AddNewExportMapping {
                $Global:UpsMappingAddNewExportCalled = $true
                return $true
            } -PassThru -Force | Add-Member ScriptMethod AddNewMapping {
                $Global:UpsMappingAddNewMappingCalled = $true
                return $true
            } -PassThru -Force

            $connection = [PSCustomObject]@{
                DisplayName        = "Contoso"
                IsDirectorySerivce = $true
                Type               = "ActiveDirectoryImport"
                PropertyMapping    = $propertyMapping
            } | Add-Member -MemberType ScriptMethod -Name GetType -Value {
                return @{
                    FullName = "Microsoft.Office.Server.UserProfiles.ActiveDirectoryImportConnection"
                } | Add-Member -MemberType ScriptMethod -Name GetMethods -Value {
                    return @{
                        Name = "ADImportPropertyMappings"
                    } | Add-Member -MemberType ScriptMethod -Name Invoke -Value {
                        return @(
                            (([PSCustomObject]"Microsoft.Office.Server.UserProfiles.ADImport.UserProfileADImportPropertyMapping") `
                                | Add-Member -MemberType ScriptMethod -Name GetType -Value {
                                    return @{
                                        FullName = ""
                                    } | Add-Member -MemberType ScriptMethod -Name GetMembers -Value {
                                        return @(
                                            (@{
                                                    MemberType = "Property"
                                                    Name       = "ProfileProperty"
                                                } | Add-Member -MemberType ScriptMethod -Name GetValue -Value {
                                                    return "WorkEmailUpdate"
                                                } -PassThru -Force),
                                            (@{
                                                    MemberType = "Property"
                                                    Name       = "ADAttribute"
                                                } | Add-Member -MemberType ScriptMethod -Name GetValue -Value {
                                                    return "department"
                                                } -PassThru -Force)
                                        )
                                    } -PassThru -Force
                                } -PassThru -Force
                            ),
                            (([PSCustomObject]"Microsoft.Office.Server.UserProfiles.ADImport.UserProfileADImportPropertyMapping") `
                                | Add-Member -MemberType ScriptMethod -Name GetType -Value {
                                    return @{
                                        FullName = ""
                                    } | Add-Member -MemberType ScriptMethod -Name GetMembers -Value {
                                        return @()
                                    } -PassThru -Force
                                } -PassThru -Force
                            )
                        )
                    } -PassThru -Force
                } -PassThru -Force
            } -PassThru -Force

            $ConnnectionManager = @{
                $($connection.DisplayName) = $connection
            }
            Mock -CommandName New-Object -MockWith {
                $ProfilePropertyManager = @{
                    "Contoso" = $connection
                } | Add-Member ScriptMethod GetCoreProperties {
                    $Global:UpsConfigManagerGetCorePropertiesCalled = $true
                    return ($coreProperties)
                } -PassThru | Add-Member ScriptMethod GetProfileTypeProperties {
                    $Global:UpsConfigManagerGetProfileTypePropertiesCalled = $true
                    return $userProfileSubTypePropertiesUpdateProperty
                } -PassThru
                return (@{
                        ProfilePropertyManager = $ProfilePropertyManager
                        ConnectionManager      = $ConnnectionManager
                    } | Add-Member ScriptMethod IsSynchronizationRunning {
                        $Global:UpsSyncIsSynchronizationRunning = $true
                        return $false
                    } -PassThru   )
            } -ParameterFilter {
                $TypeName -eq "Microsoft.Office.Server.UserProfiles.UserProfileConfigManager" }


            It "Should return true when the Test method is called" {
                $testParamsUpdateProperty.Ensure = "Present"
                $testParamsUpdateProperty.PropertyMappings[0].Direction = "Import"
                $testresults = Test-TargetResource @testParamsUpdateProperty
                $testresults | Should be $true
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:SPDscHelper.CleanupScript -NoNewScope
