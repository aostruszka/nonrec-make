extern void function_dir_3_file1(void);

int main()
{
  // To make dependency on shared library from Dir_3
  function_dir_3_file1();
  return 0;
}
