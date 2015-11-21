properties {
  $configuration = "Debug"
  $framework = "4.5"
  $deploymentTarget = $env:DEPLOYMENT_TARGET
  $target_path = "c:\lazysystem\"
}

Add-Type -assembly "system.io.compression.filesystem"

Import-Module $PSScriptRoot\tools\psake\psake.psm1  



task default -depends VerifyTask

task InitializeTask{
  write-host "Starting deployment of LazySystem."
  write-host "ENVIRONMENT: $($deploymentTarget)"
}


task UninstallServiceTask -depends CleanTask { 
  UninstallService "LazyService" "DEV"
}


task DeployDBTask -depends UninstallServiceTask { 
  write-host "Deploying DB..."
}   

task DeployServiceTask -depends DeployDBTask { 
  DeployService "LazyService" $env
  
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
    
    $path = Get-PathToService $service $env
    $unpackFrom = "$path\$service.zip"
    $unpackTo = "$path\unpack\"
    write-host "Unpacking $unpackFrom ==> $unpackTo"
    [io.compression.zipfile]::ExtractToDirectory($unpackFrom, $unpackTo)

    copy-item "$unpackTo\*" $target_path -recurse -force

    exec { &"$target_path$service\$service.exe" install}

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

function Get-PathToService{
  "$PSScriptRoot\build"
}
