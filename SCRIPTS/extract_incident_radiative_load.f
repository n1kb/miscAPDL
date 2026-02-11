!   Commands inserted into this file will be executed immediately after the ANSYS /POST1 command.

!   Active UNIT system in Workbench when this object was created:  Metric (m, kg, N, s, mV, mA)
!   NOTE:  Any data that requires units (such as mass) is assumed to be in the consistent solver unit system.
!                See Solving Units in the help system for more information.

!#--------------------------------DECRIPTION--------------------------------#
!This script selects all the 3D elements of type SURF252 (3-D Radiosity Surface Elements)
!and exports in a CSV files the elements centroid position, surface area and incident radiative
!heat flux. 
!If you want to export other data from the elements, such as reflected radiative heat flux, 
!etc.. just modify the array dimension adding additional columns (*DIM,QRAD_ELEM,ARRAY,NELEM, <columns>)
!and add *GET commands inside the do loop.
!#--------------------------------DECRIPTION--------------------------------#

/POST1                  !enter postprocessor
FILE,'file','rth'       !load correct thermal results file
INRES,ALL               !select all results for loading (include noda, element etc and misc results)
SET, LAST               !set last timestep  

ALLSEL                  !select all elements
ETLIST                  !list all element types (written in POST output)

ESEL,NONE               !clear any previous selection
ESEL,S,ENAME,,SURF252        !select all elements of type 252 (surface to surface radiation elements)

*GET,CURRE,elem,0,num,min   !gets the minimum index of the selected elements
*GET,NELEM, ELEM,0,COUNT    !gets the total number of selected elements
*DIM,QRAD_ELEM,ARRAY,NELEM, 5   !creates an array 5 columns wide and NELEM rows long

!loops over the elements and extracts the relevant info
*do,I,1,NELEM
    *get,QRAD_ELEM(I, 1),ELEM,CURRE,NMISC,1     !x position of the element centroid
    *get,QRAD_ELEM(I, 2),ELEM,CURRE,NMISC,2     !y position of the element centroid
    *get,QRAD_ELEM(I, 3),ELEM,CURRE,NMISC,3     !z position of the element centroid
    *get,QRAD_ELEM(I, 4),ELEM,CURRE,NMISC,4     !element area   
    *get,QRAD_ELEM(I, 5),ELEM,CURRE,NMISC,10    !radiative net heat flow (negative if entering the element, positive if exiting)
    *get,CURRE,ELEM,CURRE,NXTH                  !get next element ID for next loop iteration
*enddo

!writes the array to file
*CFOPEN,'rad_heat',TXT      ! open file (in soulition folder, otherwise specify the full path)
*VWRITE,'X, Y, Z,',' AREA[m2','], q"[W/','m2K]'     !writes header
(A8, A8, A8, A4)        !format specifier
*VWRITE,QRAD_ELEM(1,1),',',QRAD_ELEM(1,2),',',QRAD_ELEM(1,3),',',QRAD_ELEM(1,4),',',QRAD_ELEM(1,5)  !writes data
(F20.10,A,F20.10,A,F20.10,A,F20.10,A,F20.10)    !format spefier
*CFCLSE     !close file
