1. Detailed steps:
  - Step 1: Download corresponding Latex distributions in the website: https://www.latex-project.org/get/. I downloaded MacTex for my MacBook. (After downloading and installing it, I will find there are two applications in your Launchpad: LaTexiT and TeXShop.);
  - Step 2: Download VSCode in its official website: https://code.visualstudio.com/;
  - Step 3: Open your VSCode and find the Extensions button (the fifth button in the left toolbar of the VSCode interface). Click it and search 'LaTex Workshop'. Install this extension;
  - Step 4: Use the shortcut: ctrl+shift+p(Mac:command+shift+p) to open a command toolbar (will appear at the top of the interface). Search 'Preference: Open Settings(json)' and click the json file.
  - Step 5: You will find some code like the following. We firstly can leave the code as it is.

```
  "latex-workshop.latex.tools": [
    {
        "name": "xelatex",
        "command": "xelatex",
        "args": [
            "-synctex=1",
            "-interaction=nonstopmode",
            "-file-line-error",
            "-pdf",
            "%DOC%"
        ]
    },
    {
        "name": "latexmk",
        "command": "latexmk",
        "args": [
            "-synctex=1",
            "-interaction=nonstopmode",
            "-file-line-error",
            "-pdf",
            "-outdir=%OUTDIR%",
            "%DOC%"
        ],
        "env": {}
    },
......
   {
        "name": "tectonic",
        "command": "tectonic",
        "args": [
            "--synctex",
            "--keep-logs",
            "%DOC%.tex"
        ],
        "env": {}
    }
        ],
        "json.schemas": [
        ],
}
```

  - Step 6: Create a .tex file to test the functions. You can copy the following lines to your file:

```
  \documentclass{report}
  \title{Data Analysis Report}
  \author{Apocalypse}
  \date{\today}
  \begin{document}
  \maketitle
  \section{Datasets}
  1. Dataset1;\par
  2. Dataset2;\par
  3. Dataset3
  \section{Research question}
  1. How... 
  \end{document}
```

  When you create a .tex file, you will find that a new button TEX appears at the left of your VSCode interface (below the Extension button). Click it and find the 'Build LaTeX project' command, click it to see what will happen. If there is no error, you can choose a way to view the PDF file in the 'View LaTeX PDF' section and have a look at the file. If you get some notification like this one: 'recipe terminated with fatal error spawn latexmk enoent', then let's move to the next section : )

2. Problems/Erros that I met and solutions
  - 1) How to solve Error: 'recipe terminated with fatal error spawn latexmk enoent'
    - Step 1: Check if you have latexmk installed. You can download TeX Live Utility to see all the packages installed and install those that you haven't. Install or update latexmk through TeX Live Utility. (Reference: https://stackoverflow.club/install-latex-on-win10 and https://blog.csdn.net/qq_35952816/article/details/109068245)
    - Step 2 (very critical): Edit the settings.json file. Open it (as instructions in the section 1) and replace code with:

```
    "files.autoSave": "onFocusChange",
    "latex-workshop.view.pdf.viewer": "tab",
    "latex-workshop.view.pdf.hand": true,
    "latex-workshop.synctex.afterBuild.enabled": true,
    "latex-workshop.latex.tools": [
        {
            "name": "xelatex",
            "command": "xelatex",
            "args": [
                "-synctex=1",
                "-interaction=nonstopmode",
                "-file-line-error",
                "%DOCFILE%"
            ]
        },
        {
            "name": "latexmk",
            "command": "latexmk",
            "args": [
                "-synctex=1",
                "-interaction=nonstopmode",
                "-file-line-error",
                "-pdf",
                "%DOCFILE%"
            ]
        },
        {
            "name": "pdflatex",
            "command": "pdflatex",
            "args": [
                "-synctex=1",
                "-interaction=nonstopmode",
                "-file-line-error",
                "%DOCFILE%"
            ]
        },
        {
            "name": "bibtex",
            "command": "bibtex",
            "args": [
                "%DOCFILE%"
            ]
        }
    ],
    "latex-workshop.latex.recipes": [
        {
          "name": "xelatex",
          "tools": [
            "xelatex"
          ]
        },
        {
          "name": "xelatex -> bibtex -> xelatex*2",
          "tools": [
            "xelatex",
            "bibtex",
            "xelatex",
            "xelatex"
          ]
        }
      ],
      
}
```

In fact, there are many versions of code that may solve this error. The code above works for me, at least. Other versions:
- [CSDN1](https://blog.csdn.net/qq_41207620/article/details/108753001?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-2.control&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-2.control)
- [Jianshu](https://www.jianshu.com/p/538856b3e5c0)   
- [Zhihu](https://zhuanlan.zhihu.com/p/120815558)

- 2) How to solve Error: 'recipe terminated with error'
  - In fact, what I suggest is that reviewing your code in .tex file first to see if there is any spelling mistake, because this is what happened to me : )
  - Or you may want to edit the settings.json file again.

     