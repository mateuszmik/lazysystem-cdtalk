properties {
  $testMessage = 'Executed Test!'
  $compileMessage = 'Executed Compile!'
  $cleanMessage = 'Executed Clean!'
  $configuration = "Debug"
  $framework = "4.5"
  $buildDir = "$PSScriptRoot\build" 
  $zipFrom = "$PSScriptRoot\src\LazyService\LazyService\bin\Debug\"
  $zipTo = "$buildDir\LazyService.zip"
}

task default -depends Pack


task Test -depends Compile, Clean { 
    exec { 
        & "$PSScriptRoot\tools\NUnit.Console.3.0.0\nunit3-console.exe" "$PSScriptRoot\src\LazyService\LazyService.Tests\bin\Debug\LazyService.Tests.dll" --teamcity --noheader
    }
}

task Pack -depends Test{

    if(Test-Path $zipTo){

        write-host "Removing $zipTo"
        remove-item $zipTo
    }

    write-host "Checking if dir $buildDir is created"
    if(-not (test-path $buildDir)){
        write-host "Creating direcotyr $buildDir"
        New-Item -ItemType Directory -Force -Path $buildDir
    }

    Add-Type -assembly "system.io.compression.filesystem"

    write-host "Zipping $zipFrom ==> $zipTo"
    [io.compression.zipfile]::CreateFromDirectory($zipFrom, $zipTo)
}   

task Compile -depends Clean { 
  Exec { msbuild "$PSScriptRoot/src/LazyService/LazyService.sln" }
}

task Clean { 
  $cleanMessage
}