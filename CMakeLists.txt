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

    # tdlib
    add_subdirectory(td)
endif ()

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
        src/helpers/DevLog.m

        include/ChatListManager.h
        include/ChatMessageManager.h
        include/UserManager.h
        src/memory/ChatListManager.m
        src/memory/ChatMessageManager.m
        src/memory/UserManager.m

        include/ChatMessage.h
        src/models/ChatMessage.m
        )

add_executable(${NAME} ${OBJECTIVE_C_SRCS})
target_compile_options(${NAME} PUBLIC ${GNUSTEP_FLAGS})

if (NOT CMAKE_SYSTEM_NAME MATCHES "OpenBSD")
    target_link_libraries(${NAME} PUBLIC ${GNUSTEP_LIBS} ncursesw Td::TdJson)
else ()
    target_link_libraries(${NAME} PUBLIC ${GNUSTEP_LIBS} ncursesw tdjson)
endif ()