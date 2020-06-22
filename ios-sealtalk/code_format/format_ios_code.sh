#!/bin/bash

#  Created by Sin on 19/10/11.
#  Copyright (c) 2019 RongCloud. All rights reserved.

# 按照 .clang-format 格式将受 git 管理的变更的代码文件格式化

# clang-format -i -style=file 会找目录中的 .clang-format 文件，并按照其规则格式化代码

# 获取 git 更改的文件
Git_Diff=`git diff --name-only`
Clang_Format="../../document/ios/code_format/clang-format"

currentPath=`pwd`
echo "currentPath ${currentPath}"

if [ ! -f "$Clang_Format" ]; then
	echo "clang-format not exist"
	exit 0
fi

OLD_IFS=$IFS
IFS=$'\n'

for x in $Git_Diff; do
  echo "find ${x}"
  x="../../${x}"

  if [ ! -f "$x" ]; then
  	echo "can't format file $x"
  	continue;
  fi

  # .h 文件格式化代码
  result=$(echo $x | grep "\.h$")
  if [ -n "$result" ]; then
    echo "format ${x}"
    $Clang_Format -i -style=file $x
  fi

  result=$(echo $x | grep "\.m$")
  if [ -n "$result" ]; then
    echo "format ${x}"
    $Clang_Format -i -style=file $x
  fi

  result=$(echo $x | grep "\.mm$")
  if [ -n "$result" ]; then
    echo "format ${x}"
    $Clang_Format -i -style=file $x
  fi

done

IFS=$OLD_IFS

