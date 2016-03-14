void main(void)
{
  unsigned int b;
  int i;

   for (i=4200; i<4400; i++)
   {
     b = 1000000*(i);
     printf("%d %d %d\n",i,b,b%1000000);
   }
   
}

