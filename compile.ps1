enum AssertionMode {
    disabled
    enabled
    paranoid
    release
}
enum CMakeBuildType {
    Debug
    Release
    RelWithDebInfo
    MinSizeRel
}
$STATIC_LIBRARY = $false
# This determines SDL SDL_image SDL_ttf and SDL_mixer's assertion behavior.
$ASSERTION_MODE = [AssertionMode]::enabled 
$CMAKE_BUILD_TYPE = [CMakeBuildType]::Debug
# TODO: CMAKE_POSITION_INDEPENDENT
function Update {
    Write-Host "Updating" -ForegroundColor Green
    git.exe submodule update --init --recursive
}

function ClearInstallDir {
    Write-Host "Clearing Install Dir" -ForegroundColor Green
    if (Test-Path "install") {
        Remove-Item "install" -Recurse -Force
    }
}

function CompileAndInstallSDL {
    Write-Host "Entering .\sdl-deps\SDL" -ForegroundColor Green
    Set-Location .\sdl-deps\SDL
    if (Test-Path "build") {
        Remove-Item "build" -Recurse -Force
    }
    if (Test-Path "install") {
        Remove-Item "install" -Recurse -Force
    }

    $cmake_args = @()
    if ($STATIC_LIBRARY) {
        $cmake_args += "-DSDL_STATIC=ON"
        $cmake_args += "-DSDL_SHARED=OFF"
    }
    else {
        $cmake_args += "-DSDL_STATIC=OFF"
        $cmake_args += "-DSDL_SHARED=ON"
    }
    $cmake_args += "-DSDL_ASSERTIONS=$($ASSERTION_MODE.ToString())"
    $cmake_args += "-DCMAKE_BUILD_TYPE=$($CMAKE_BUILD_TYPE.ToString())"

    Write-Host "CMake Command: cmake.exe -B build -S . $($cmake_args -join ' ')"
    cmake.exe -B build -S . @cmake_args
    cmake.exe --build build
    cmake.exe --install build --prefix install
    Write-Host "Leaving .\sdl-deps\SDL" -ForegroundColor Green

    Set-Location ..\..\
    Write-Host "Copying Installed Files for SDL" -ForegroundColor Green
    Copy-Item .\sdl-deps\SDL\install install\SDL -Recurse -Force
}

# 摆烂了
function CompileAndInstallSDLImage {
    Write-Host "Entering .\sdl-deps\SDL_image" -ForegroundColor Green
    Set-Location .\sdl-deps\SDL_image
    if (Test-Path "build") {
        Remove-Item "build" -Recurse -Force
    }
    if (Test-Path "install") {
        Remove-Item "install" -Recurse -Force
    }

    $cmake_args = @()
    $cmake_args += "-DSDL3_DIR=..\..\install\SDL\lib\cmake\SDL3"
    $cmake_args += "-DCMAKE_BUILD_TYPE=$($CMAKE_BUILD_TYPE.ToString())"
    if ($STATIC_LIBRARY) {
        $cmake_args += "-DBUILD_SHARED_LIBS=OFF"
    }
    else {
        $cmake_args += "-DBUILD_SHARED_LIBS=ON"
    }

    Write-Host "CMake Command: cmake.exe -B build -S . $($cmake_args -join ' ')"
    cmake.exe -B build -S . @cmake_args
    cmake.exe --build build
    cmake.exe --install build --prefix install
    Write-Host "Leaving .\sdl-deps\SDL_image" -ForegroundColor Green

    Set-Location ..\..\
    Write-Host "Copying Installed Files for SDL_image" -ForegroundColor Green
    Copy-Item .\sdl-deps\SDL_image\install install\SDL_image -Recurse -Force
}

function CompileAndInstallSDLFont {
    Write-Host "Entering .\sdl-deps\SDL_ttf" -ForegroundColor Green
    Set-Location .\sdl-deps\SDL_ttf
    if (Test-Path "build") {
        Remove-Item "build" -Recurse -Force
    }
    if (Test-Path "install") {
        Remove-Item "install" -Recurse -Force
    }

    $cmake_args = @()
    $cmake_args += "-DSDL3_DIR=..\..\install\SDL\lib\cmake\SDL3"
    $cmake_args += "-DCMAKE_BUILD_TYPE=$($CMAKE_BUILD_TYPE.ToString())"
    if ($STATIC_LIBRARY) {
        $cmake_args += "-DBUILD_SHARED_LIBS=OFF"
    }
    else {
        $cmake_args += "-DBUILD_SHARED_LIBS=ON"
    }
    $cmake_args += "-DSDLTTF_VENDORED=ON"

    Write-Host "CMake Command: cmake.exe -B build -S . $($cmake_args -join ' ')"
    cmake.exe -B build -S . @cmake_args
    cmake.exe --build build
    cmake.exe --install build --prefix install
    Write-Host "Leaving .\sdl-deps\SDL_ttf" -ForegroundColor Green

    Set-Location ..\..\
    Write-Host "Copying Installed Files for SDL_ttf" -ForegroundColor Green
    Copy-Item .\sdl-deps\SDL_ttf\install install\SDL_ttf -Recurse -Force
}

function CompileAndInstallSDLMixer {
    Write-Host "Entering .\sdl-deps\SDL_mixer" -ForegroundColor Green
    Set-Location .\sdl-deps\SDL_mixer
    if (Test-Path "build") {
        Remove-Item "build" -Recurse -Force
    }
    if (Test-Path "install") {
        Remove-Item "install" -Recurse -Force
    }

    $cmake_args = @()
    $cmake_args += "-DSDL3_DIR=..\..\install\SDL\lib\cmake\SDL3"
    $cmake_args += "-DCMAKE_BUILD_TYPE=$($CMAKE_BUILD_TYPE.ToString())"
    if ($STATIC_LIBRARY) {
        $cmake_args += "-DBUILD_SHARED_LIBS=OFF"
    }
    else {
        $cmake_args += "-DBUILD_SHARED_LIBS=ON"
    }

    Write-Host "CMake Command: cmake.exe -B build -S . $($cmake_args -join ' ')"
    cmake.exe -B build -S . @cmake_args
    cmake.exe --build build
    cmake.exe --install build --prefix install
    Write-Host "Leaving .\sdl-deps\SDL_mixer" -ForegroundColor Green

    Set-Location ..\..\
    Write-Host "Copying Installed Files for SDL_mixer" -ForegroundColor Green
    Copy-Item .\sdl-deps\SDL_mixer\install install\SDL_mixer -Recurse -Force
}

function MixTogether {
    if (Test-Path "old-install") {
        Remove-Item .\old-install -Recurse -Force
    }

    Move-Item .\install .\old-install
    New-Item -Path install -ItemType Directory | Out-Null

    $libs = @("SDL", "SDL_image", "SDL_ttf", "SDL_mixer")
    $folders = @("bin", "include", "lib", "share")

    foreach ($lib in $libs) {
        foreach ($folder in $folders) {
            $source = "old-install\$lib\$folder"
            $dest = "install\$folder"

            # 如果源目录不存在，跳过
            if (-Not (Test-Path $source)) { continue }

            # 确保目标目录存在
            if (-Not (Test-Path $dest)) {
                New-Item -Path $dest -ItemType Directory | Out-Null
            }

            # 直接递归复制源目录下的所有内容到目标目录
            Copy-Item "$source\*" $dest -Recurse -Force
        }
    }

    Remove-Item .\old-install -Recurse -Force
}

# ClearInstallDir
# Update
# CompileAndInstallSDL
# CompileAndInstallSDLImage
# CompileAndInstallSDLFont
# CompileAndInstallSDLMixer
MixTogether