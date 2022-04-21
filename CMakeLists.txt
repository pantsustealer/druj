set(NAME druj)

cmake_minimum_required(VERSION 3.16)
set(GNUSTEP gnustep-config)
project(${NAME})

find_package(PkgConfig REQUIRED)

if (NOT CMAKE_SYSTEM_NAME MATCHES "OpenBSD")
    # ncurses
    set(CURSES_NEED_WIDE TRUE)
    find_package(Curses REQUIRED)
    include_directories(${CURSES_INCLUDE_DIR})
endif ()

add_custom_target(prepare ALL
        ${CMAKE_COMMAND} -DCMAKE_BUILD_TYPE=Release .. &&
        ${CMAKE_COMMAND} --build . --target prepare_cross_compiling &&
        cd ../td && php-8.0 SplitSource.php
        )

# tdlib
add_subdirectory(td)

#####################################################################################
#
# gnustep
#
execute_process(COMMAND ${GNUSTEP} --objc-flags
        OUTPUT_VARIABLE GNUSTEP_FLAGS
        OUTPUT_STRIP_TRAILING_WHITESPACE)
separate_arguments(GNUSTEP_FLAGS UNIX_COMMAND ${GNUSTEP_FLAGS})

execute_process(COMMAND ${GNUSTEP} --base-libs
        OUTPUT_VARIABLE GNUSTEP_LIBS
        OUTPUT_STRIP_TRAILING_WHITESPACE)

#####################################################################################

set(OBJECTIVE_C_SRCS
        src/main.m
        include/Application.h
        src/Application.m
        include/Telegram.h
        src/Telegram.m
        include/Tui.h
        src/Tui.m
        include/Store.h
        src/Store.m

        # helpers
        include/DevLog.h
        include/DateHelper.h
        src/helpers/DevLog.m
        src/helpers/DateHelper.m

        include/AbstractManager.h
        include/ChatListManager.h
        include/ChatMessageManager.h
        include/ChatUserManager.h
        src/memory/AbstractManager.m
        src/memory/ChatListManager.m
        src/memory/ChatMessageManager.m
        src/memory/ChatUserManager.m

        # models
        include/ChatMessageModel.h
        include/ChatUserModel.h
        src/models/ChatMessageModel.m
        src/models/ChatUserModel.m
        )

add_executable(${NAME} ${OBJECTIVE_C_SRCS})
target_compile_options(${NAME} PUBLIC ${GNUSTEP_FLAGS})

target_link_libraries(${NAME} PUBLIC ncursesw ${GNUSTEP_LIBS} Td::TdJson)
#target_link_libraries(${NAME} PUBLIC ncursesw ${GNUSTEP_LIBS} PRIVATE Td::TdJsonStatic)