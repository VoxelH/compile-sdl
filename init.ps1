git.exe init

git.exe submodule add --name SDL https://github.com/libsdl-org/SDL.git sdl-deps/SDL
git.exe submodule add --name SDL_ttf https://github.com/libsdl-org/SDL_ttf.git sdl-deps/SDL_ttf
git.exe submodule add --name SDL_image https://github.com/libsdl-org/SDL_image.git sdl-deps/SDL_image
git.exe submodule add --name SDL_mixer https://github.com/libsdl-org/SDL_mixer.git sdl-deps/SDL_mixer

# 递归初始化并更新所有子模块（包括它们自己的子模块）
git.exe submodule update --init --recursive