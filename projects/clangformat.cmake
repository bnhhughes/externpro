# clangformat
include(${CMAKE_CURRENT_LIST_DIR}/llvm.cmake)
xpGetArgValue(${PRO_LLVM} ARG VER VALUE llvmVer)
set(PRO_CLANGFORMAT
  NAME clangformat
  SUPERPRO clang
  WEB "clang-format" http://clang.llvm.org/docs/ClangFormat.html "ClangFormat documentation"
  LICENSE "open" "http://clang.llvm.org/features.html#license" "LLVM 'BSD' License"
  DESC "used to format C/C++/Obj-C code"
  VER ${llvmVer}
  )
########################################
function(build_clangformat)
  if(NOT (XP_DEFAULT OR XP_PRO_LLVM))
    return()
  endif()
  find_package(PythonInterp 2.7)
  if(NOT PYTHONINTERP_FOUND)
    message(AUTHOR_WARNING "Unable to build clang-format, required python not found")
    return()
  endif()
  set(XP_DEPS llvm llvm_clang)
  set(XP_CONFIGURE
    -DLLVM_TARGETS_TO_BUILD:STRING=X86
    -DBUILD_CLANG_FORMAT_VS_PLUGIN=ON
    )
  # since we only need a release executable...
  set(BUILD_CONFIGS Release)
  configure_file(${PRO_DIR}/use/usexp-clangformat-config.cmake ${STAGE_DIR}/share/cmake/
    @ONLY NEWLINE_STYLE LF
    )
  if(MSVC)
    set(buildTgt clang_format_vsix)
  else()
    set(buildTgt clang-format)
  endif()
  xpCmakeBuild(llvm "${XP_DEPS}" "${XP_CONFIGURE}" llvmTgt NO_INSTALL BUILD_TARGET ${buildTgt} TGT format)
  ExternalProject_Get_Property(${llvmTgt} BINARY_DIR)
  ExternalProject_Add(clangformat_install DEPENDS ${llvmTgt}
    DOWNLOAD_COMMAND "" DOWNLOAD_DIR ${NULL_DIR}
    SOURCE_DIR ${NULL_DIR} CONFIGURE_COMMAND "" BUILD_COMMAND ""
    BINARY_DIR ${BINARY_DIR}/tools/clang/tools/clang-format
    INSTALL_COMMAND ${CMAKE_COMMAND} -P cmake_install.cmake
    INSTALL_DIR ${STAGE_DIR}
    )
  if(MSVC)
    ExternalProject_Add_Step(clangformat_install clangformat_install_vsix
      COMMAND ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/pkg
      COMMAND ${CMAKE_COMMAND} -E copy_if_different ${BINARY_DIR}/Release/bin/ClangFormat.vsix ${STAGE_DIR}/pkg
      DEPENDEES install
      )
  endif()
  set_property(TARGET clangformat_install PROPERTY FOLDER ${bld_folder})
endfunction()
