echo Execute update for katana packages...
call flutter pub upgrade
call flutter packages pub run build_runner build --delete-conflicting-outputs
call flutter format .
call echo y | flutter pub publish