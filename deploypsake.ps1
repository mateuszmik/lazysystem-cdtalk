properties {
  $configuration = "Debug"
  $framework = "4.5"
  $deploymentTarget = $env:DEPLOYMENT_TARGET
  $target_path = "c:\lazysystem\"
  $roundhouse_path= ".\tools\roundhouse\rh.exe"
}

Add-Type -assembly "system.io.compression.filesystem"

Import-Module $PSScriptRoot\tools\psake\psake.psm1  
Import-Module $PSScriptRoot\tools\poweryaml\poweryaml.psm1


task default -depends VerifyTask

task InitializeTask{
  write-host "Starting deployment of LazySystem."
  write-host "ENVIRONMENT: $($deploymentTarget)"
}


task UninstallServiceTask -depends CleanTask { 
  UninstallService "LazyService" $deploymentTarget
}


task DeployDBTask -depends UninstallServiceTask { 
  
   $connectionString = "Server=localhost\SQLEXPRESS; Database=lazydb; Integrated Security=False;User Id=sa;Password=Global2000;"
   exec {& $roundhouse_path /debug /cs=$connectionString /dt=sqlserver /o=".\database\logs" /f="$PSScriptRoot\database" /u=upgrade /vf=.\database\version.xml /vx=/version /r=/lazysystem /ct=18000 /cta=18000 /simple /silent /donotbackupdatabase}
}   

task DeployServiceTask -depends DeployDBTask { 
  DeployService "LazyService" $deploymentTarget
  
}

task CleanTask -depends InitializeTask{ 
  write-host "Cleaning up..."  

  if(test-path "$PSScriptRoot\build\unpack"){
    remove-item "$PSScriptRoot\build\unpack\" -force -recurse
  }
}

task VerifyTask -depends DeployServiceTask{ 
  write-host "Veryfying..."  
}


function DeployService($service, $env){
    write-host "Deploying Service [$service] to environment $env"
    
    CopyService $service $env
    $serviceNameInThisEnv = GetYmlValue $service "config.serviceName.$env"

    exec { &"$target_path$service\$service.exe" install -servicename:$serviceNameInThisEnv -displayname:$serviceNameInThisEnv}

    exec { &"$target_path$service\$service.exe" start}
}

function UninstallService($service, $env){
    write-host "Uninstalling Service [$service] to environment $env"
    $pathToUninstall = "$target_path$service\$service.exe"

    if(Test-Path $pathToUninstall){
      exec { &"$target_path$service\$service.exe" uninstall}  
    }
    else{
      write-host "No service, nothing to do"
    }
}

function GetYmlValue($serviceName, $pathToYml){
  write-host resolving $serviceName $pathToYml
  $yml = Get-Yaml -FromFile (Resolve-Path $PSScriptRoot\config.yml)

  $component = ($yml.components | where {$_.component -eq $serviceName})
  $var = "`$component.$pathToYml"
  $value = invoke-expression $var
  write-host "value: $value"
  $value
}


function CopyService($service, $env){
  $path = Get-PathToService $service $env
    $unpackFrom = "$path\$service.zip"
    $unpackTo = "$path\unpack\"
    write-host "Unpacking $unpackFrom ==> $unpackTo"
    [io.compression.zipfile]::ExtractToDirectory($unpackFrom, $unpackTo)

    copy-item "$unpackTo\*" $target_path -recurse -force
}

function Get-PathToService{
  "$PSScriptRoot\build"
}
