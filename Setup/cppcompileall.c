#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <windows.h>

typedef struct LL {

 char *fn;
 struct LL *next;
} LL;

int main (int argc, char **argv);
void removeobj (void);
char **listing (void);
LL * sort (LL *L);
LL * merge (LL *a, LL* b);
LL * split (LL *L);
void disposelist (char **l);
void copyout (char *old);
void copyerr (char *old);
int ccmp (char *a, char *b);

int main (int argc, char **argv) {

  char *cname, *cmdname, *outname, *exename, *cmd, *objname,
       **l;
  int i;
  FILE *txt;

 if (argc != 2) return EXIT_FAILURE;
 if (strlen (argv[1]) < 4 || strcmp (&argv[1][strlen(argv[1])-4],".exe") != 0) {printf ("NOT A VALID FILE\n");return EXIT_FAILURE;}
 argv[1][strlen(argv[1])-4] = 0;
 cname = malloc (strlen (argv[1])+strlen (".cpp")+1);
 sprintf (cname,"%s.cpp",argv[1]);
 outname = malloc (strlen (argv[1])+strlen (".cppcompileallout")+1);
 sprintf (outname,"%s.cppcompileallout",argv[1]);
 exename = malloc (strlen (argv[1])+strlen (".exe")+1);
 sprintf (exename,"%s.exe",argv[1]);
 objname = malloc (strlen (argv[1])+strlen (".obj")+1);
 sprintf (objname,"%s.obj",argv[1]);
 cmdname = malloc (strlen (argv[1])+strlen (".cppcompileall.bat")+1);
 sprintf (cmdname,"%s.cppcompileall.bat",argv[1]);
 remove (exename);
 txt = fopen (cmdname,"wb");
 fprintf (txt,"@echo off\r\n");
 fprintf (txt,"call \"C:\\Program Files (x86)\\Microsoft Visual Studio\\2019\\Professional\\Common7\\Tools\\VsDevCmd.bat\"\r\n");
 fprintf (txt,"cl ");
 l = listing ();
 for (i=0; l[i]; i++)
  if (strlen(l[i]) >=4 && strcmp (".cpp",&l[i][strlen(l[i])-4])==0)
   fprintf (txt,"/Tp \"%s\" ",l[i]);
 disposelist (l);
 fprintf (txt,"/O2 /EHsc /W2 /link /OUT:%s\r\n",exename);
 fclose (txt);
 cmd = malloc(strlen ("cmd /c \"")+strlen (cmdname)+strlen ("\" > \"")+strlen (outname)+strlen ("\" 2>&1")+1);
 sprintf (cmd,"cmd /c \"%s\" > \"%s\" 2>&1",cmdname,outname);
 system (cmd);
 Sleep (5000);
 remove (cmdname);
 copyout (outname);
 remove (outname);
 removeobj();
 free (cname);
 free (cmdname);
 free (outname);
 free (cmd);
 free (objname);
 return EXIT_SUCCESS;
}

void copyout (char *old) {

  FILE *of;
  int ch;

 of = fopen (old,"r");
 while (EOF!=(ch=fgetc (of)))
  fputc (ch,stdout);
 fclose (of);
}

void copyerr (char *old) {

  FILE *of;
  int ch;

 of = fopen (old,"r");
 while (EOF!=(ch=fgetc (of)))
  fputc (ch,stderr);
 fclose (of);
}

void removeobj (void) {

  char **l;
  int i;

 l = listing ();
 for (i=0; l[i]!=NULL;i++)
  if (strlen(l[i]) >= 4 && strcmp (&l[i][strlen(l[i])-4],".obj")==0)
   remove (l[i]);
 disposelist (l);
}

char **listing (void) {

  WIN32_FIND_DATA ffd;
  HANDLE hf;
  int fct, i;
  LL *L, *t;
  char *f, **l;

 L = NULL;
 fct = 0;
 while (1) {
  if (fct==0) {
   hf =  FindFirstFile ("*",&ffd);
   f = ffd.cFileName;
  } else {
   if (FindNextFile (hf,&ffd)) {
    f = ffd.cFileName;
   } else break;
  }
  fct++;
  t = L;
  L = malloc (sizeof (LL));
  L->fn = malloc (strlen (f)+1);
  strcpy (L->fn,f);
  L->next = t;
 }
 L = sort (L);
 l = malloc ((fct+1)*sizeof (char*));
 i = 0;
 while (L != NULL) {
  l[i] = L->fn;
  t = L->next;
  free (L);
  L = t;
  i++;
 }
 l[fct] = NULL;
 FindClose (hf);
 return l;
}

LL * sort (LL *L) {

  LL *t;

 if (L==NULL || L->next == NULL) return L;
 t = split (L);
 L = sort (L);
 t = sort (t);
 return merge (L,t);
}

LL * merge (LL *a, LL* b) {

 if (b==NULL) return a;
 if (a== NULL || ccmp (a->fn,b->fn) > 0) return merge (b,a);
 a->next = merge (a->next,b);
 return a;
}

LL * split (LL *L) {

  LL *t;

 if (L==NULL) return NULL;
 t = L->next;
 L->next = split (t);
 return t;
}

void disposelist (char **l) {

  int i;

 for (i=0; l[i]; i++) free (l[i]);
 free (l);
}

int ccmp (char *a, char *b) {

  char *aa, *bb;
  int c,i;

 aa = malloc (strlen(a)+1);
 strcpy (aa,a);
 for (i=0; i < strlen(aa); i++) aa[i]=tolower(aa[i]);
 bb = malloc (strlen(b)+1);
 strcpy (bb,b);
 for (i=0; i < strlen(bb); i++) bb[i]=tolower(bb[i]);
 c = strcmp (aa,bb);
 free (aa);
 free (bb);
 return c;
}
