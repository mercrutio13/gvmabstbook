\ProvidesPackage{gvmabstbook}[2022/08/19 Abstract Book package]
\LoadClass{article}
\NeedsTeXFormat{LaTeX2e}

\RequirePackage[utf8]{inputenc}
\RequirePackage{datatool}

\RequirePackage{kvoptions}

\RequirePackage{geometry}
\geometry{margin=1.75in}
\RequirePackage{xcolor}
\RequirePackage{graphicx}

\RequirePackage{texdate}

\RequirePackage[hidelinks]{hyperref} %

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%	kvoptions Setup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\SetupKeyvalOptions{
	family=GMAB,
	prefix=GMAB@
}

%\DeclareStringOption[Session]{sessionheader}

\ProcessKeyvalOptions*

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%	Variables and Accessors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	\newcommand{\@defaultTitleImageSize}{4cm}

	\newcommand*{\@confTitle}{}
	\newcommand*{\@confSubTitle}{}
	\newcommand*{\@confLocation}{}
	\newcommand*{\@confImage}{}
	\newcommand*{\@confDateRange}{}
	\newcommand{\@setConfData}[8]{
		\renewcommand{\@confTitle}{#1}
		\renewcommand{\@confSubTitle}{#2}
		\renewcommand*{\@confLocation}{#3}
		\renewcommand*{\@confImage}{#4}
		\initdate{#5}{#6}{#7}
		\savedate{confStartDate}
		\def\setdateformat{e\ b\ Y}
		\renewcommand*{\@confDateRange}{#8}
	}

	\newcommand*{\@fName}{}
	\newcommand*{\@mName}{}
	\newcommand*{\@sName}{}
	\newcommand*{\@Title}{}
	\newcommand*{\@Affil}{}
	\newcommand{\@Abst}{}

	\newcommand*{\FirstName}[1]{\renewcommand*{\@fName}{#1}}
	\newcommand*{\MiddleName}[1]{\renewcommand*{\@mName}{#1}}
	\newcommand*{\Surname}[1]{\renewcommand*{\@sName}{#1}}
	\newcommand*{\AbsTitle}[1]{\renewcommand*{\@Title}{#1}}
	\newcommand*{\Affil}[1]{\renewcommand*{\@Affil}{#1}}
	\newcommand{\Abstract}[1]{\renewcommand{\@Abst}{#1}}
	
	\newcommand{\@setData}[6]{
		\renewcommand*{\@fName}{#1}
		\renewcommand*{\@mName}{#2}
		\renewcommand*{\@sName}{#3}
		\renewcommand*{\@Title}{#4}
		\renewcommand*{\@Affil}{#5}
		\renewcommand{\@Abst}{#6}
	}

	\newcommand{\@resetAbsData}{  % TODO preview as option
		\@setData{{\color{red}FIRST NAME}}
			{}
			{{\color{red}SURNAME}}
			{{\color{red}TITLE}}
			{{\color{red}AFFILIATION}}
			{}
	}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%	Abstract Database make-commands
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%	Import and make speakers database

\newcommand{\makecsvdatabase}[1]{
	
	\DTLloaddb[noheader]{speakcsv}{#1}
	
	\DTLnewdb{speakers} % Build speaker database
	\DTLforeach*{speakcsv}{\time=Column1}{%		
		\DTLforeachkeyinrow{\filename}{ % iterate through speakers
			\DTLifnumeq{\dtlcol}{1}{}{ % skip first (time) column
				\DTLifnullorempty{\filename}{}{ % test for and skip empty cells
					\@resetAbsData					
					\DTLnewrow{speakers} % add a row to the database
					% add sort data to new row from \time, \day, and abstracts/\filename.tex
					\dtlexpandnewvalue
					\DTLnewdbentry{speakers}{Time}{\time}
					\DTLadd{\colday}{\dtlcol}{-1}				
					\DTLnewdbentry{speakers}{Day}{\colday}
					\DTLnewdbentry{speakers}{Filename}{\filename}
					\input{abstracts/\filename} % TODO error checking
					\DTLnewdbentry{speakers}{Title}{\@Title}%
					\DTLnewdbentry{speakers}{First}{\@fName}%
					\DTLnewdbentry{speakers}{Middle}{\@mName}%
					\DTLnewdbentry{speakers}{Surname}{\@sName}%
					\DTLifnullorempty{\@mName}
						{\DTLnewdbentry{speakers}{Name}{\@sName, \@fName}}
						{\DTLnewdbentry{speakers}{Name}{\@sName, \@fName\ \@mName}}
					\DTLnewdbentry{speakers}{UID}{\DTLrowcount{speakers}}%
					\dtlnoexpandnewvalue
				}
			}
		}
	}
	\DTLdeletedb{speakcsv} % to unload import database
%	\DTLsort{Day,Time}{speakers} % leave database in chronological order
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%	Make titlepage

\newcommand{\makeConfTitle}[9][\@defaultTitleImageSize]{

	\@setConfData{#2}{#3}{#4}{#5}{#6}{#7}{#8}{#9}
	\begin{titlepage}
		\begin{center}	        
	        
	        \Huge\textbf{\@confTitle}

	        \vspace*{0.5cm}
			\Large \@confSubTitle
			
			\vspace*{1.0cm}
			\textbf{Book of Abstracts}			
			
			\vfill
			
			\makebox[\textwidth]{\includegraphics[width={#1}]{images/\@confImage}}
			
			\vspace*{0.5cm}
			
			\large \@confLocation \\ 
			\printdate 
			\DTLadd{\@tempRange}{\@confDateRange}{-1}
			\advancebydays{\@tempRange} 
			- \printdate
			\restoredate{confStartDate}
		\end{center}
	\end{titlepage}
	
%	\addtocontents{toc}{~\hfill\textbf{Page}\par}
%	\tableofcontents
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%	Make ToC

\newcommand{\makeToC}{
	\newgeometry{margin=2cm}
	\@makeAlphaToC
	\@makeCronToC
}

\newcommand{\@makeAlphaToC}{
	\clearpage
	\DTLsort{Surname}{speakers} % alphabetical order
	
	{\huge\textbf{List of Abstracts}} \vspace*{.5cm}
	
	\DTLforeach{speakers}{\name=Name,\title=Title,\u=UID}{
		\@printToCLine{\name}{\title}{\u}
	}
}

\newcommand{\@makeCronToC}{
	\clearpage
	\DTLsort{Day,Time}{speakers} % alphabetical order
	
	{\huge\textbf{Schedule}} \vspace*{.5cm}
	
	\DTLconverttodecimal{0}{\daycount}
	\restoredate{confStartDate}
	\def\setdateformat{A, e\ B\ Y}
	\begin{tabular}{r p{.8\linewidth}}
	\DTLforeach{speakers}{\name=Name,\tday=Day,\title=Title,\time=Time,\filename=Filename,\u=UID}{
		\DTLifnumgt{\tday}{\daycount}{			
			\end{tabular}
				\vspace*{-1cm}
				\subsection*{\underline\printdate}
				\advancebydays{1}
				\DTLadd{\daycount}{\daycount}{1}
				\vspace*{-.2cm}
			\begin{tabular}{r p{.9\linewidth}}
		}{}
		\hyperref[\u]{\time} & \hyperref[\u]{\textbf{\name}} \\
		& \hyperref[\u]{\textit{\title}} \\
	}
	\end{tabular}
}

\newcommand{\@printToCLine}[3]{ % modify for custom line formats, eg. for \makeCronToC
	
	\hyperref[#3]{
	\hspace*{-1cm}\textbf{#1} \\
	\textit{#2} \dotfill
	} \pageref{#3}
		
	\vspace{4pt}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%	Make timetables

\newcommand{\maketimetable}{
%	\clearpage	
%	
%	\DTLsort{Day,Time}{speakers} % chronological order
%
%%	\begin{table}
%%		\DTLdisplaydb{speakers}
%%	\end{table}
%	
%%	\restoredate{confStartDate}
%%	
%%	\foreach \n in {2,...,\DTLcolumncount{speakcsv}}{
%%		\def\@tempDate{\n}
%%		\DTLsetheader{speakcsv}{Column\n}{\@tempDate}
%%		\advancebydays{1}
%%	}	
%
%%	SKRIVE DIN EGEN BORD!!!!!!!
%	
%	\begin{table}
%		\DTLdisplaydb{speakcsv}
%	\end{table}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%	Make abstracts

\newcommand{\makeabstbook}{
	
	\newgeometry{margin=1.25in}
	\DTLsort{Day,Time}{speakers} % leave database in chronological order
	\DTLconverttodecimal{0}{\daycount}
	\restoredate{confStartDate}
	\def\setdateformat{A,\ e\ B\ Y}
	
	\DTLforeach{speakers}{\u=UID,\f=First,\m=Middle,\s=Surname,\tday=Day,\time=Time,\filename=Filename}{
		\DTLifnumgt{\tday}{\daycount}{
			\@printday
			\DTLadd{\daycount}{\daycount}{1}
		}{}
		
		\@abstBlock{\filename}	
		\label{\u}
	}
}

\newcommand{\@abstBlock}[1]{
	\filbreak % LaTeX, please don't split abstracts across multiple pages.	
	
	\@resetAbsData
	\input{abstracts/#1}
	
	\vspace{.5cm}	
	
	\noindent{\Large\f\ \s} \newline
	\textit{\@Affil}\hfill \time \hspace*{1cm}
	
	\vspace{.2cm}
	\noindent{\large\textbf{\@Title}}
		
	\DTLifnullorempty{\@Abst}{
		\vspace*{.25cm}	
	}{
		\begin{center}
		\begin{sidebar}
			\@Abst
		\end{sidebar}
		\end{center}	
	}
}

\newcommand{\@printday}{
	\clearpage
	\textsc{\LARGE\printdate}
	\advancebydays{1}
	
	\centerline{\rule{\linewidth}{.2pt}}
	\vspace{.25cm}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%	Internal utility commands
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\newsavebox{\mybox}
\newlength{\mydepth}
\newlength{\myheight}
\newenvironment{sidebar}%
	{\begin{lrbox}{\mybox}\begin{minipage}{.85\textwidth}}%
	{\end{minipage}\end{lrbox}%
		\settodepth{\mydepth}{\usebox{\mybox}}%
 		\settoheight{\myheight}{\usebox{\mybox}}%
 		\addtolength{\myheight}{\mydepth}%
		\noindent\makebox[0pt]{\hspace{-20pt}\rule[-\mydepth]{1pt}{\myheight}}%
		\usebox{\mybox}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%	Misc TEMPORARY Tools ---- COMMENT BEFORE FINAL (TODO, optional arg)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\newcommand{\tofin}[1]{ 
	{
%	\color{red} 
		#1
	}
}

\newcommand{\NR}{TBD}