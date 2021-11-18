# Purpose
This tools can be used to generate .vsmeta files for Synology DS-Video. The main purpose is to use .vsmeta to import title info of TV series.

# Usage
  1. Add video dir to DS-Video
  2. Wait until JPGs generated under @eaDir
  3. move the generated .vsmeta to the video dir.
  4. remove the new-added dir from DS-Video and add again. The title info should appear now.
  5. 

# 目的
这个工具可用于生成群晖 DS-Video的.vsmeta文件，配合work中的do.sh 批量修改文件名，主要目的是为了导入每一集的标题。

# 用法
未放入.vsmeta前，先加入DS VIDEO一次，等到 @eaDir里的 jpg缩略图生成完毕后，加入.vsmeta文件。在DS VIDEO中删除再加入一次
