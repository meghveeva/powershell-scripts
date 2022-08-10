class foo
{
   [STRING] $test = 'Hello World';

   [STRING] PrintTest()
   {
      return $this.test;
   }
}