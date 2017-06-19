for file in *.tst; do
  cp top.txt top1.txt
  cat $file >> top1.txt 
  mv top1.txt $file
done
