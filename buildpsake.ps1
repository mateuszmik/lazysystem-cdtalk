properties {
  $testMessage = 'Executed Test!'
  $compileMessage = 'Executed Compile!'
  $cleanMessage = 'Executed Clean!'
  $configuration = "Debug"
  $framework = "4.5"
}

task default -depends Test

task Test -depends Compile, Clean { 
  exec { 
        & "src\LazyService\packages\NUnit.Console.3.0.0\tools\nunit3-console.exe" "src\LazyService\LazyService.Tests\bin\Debug\LazyService.Tests.dll" --teamcity --noheader
    }

}

task Compile -depends Clean { 
  Exec { msbuild "src/LazyService/LazyService.sln" }
}

task Clean { 
  $cleanMessage
}