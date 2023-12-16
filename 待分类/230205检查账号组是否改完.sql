select Department ,count(1)
from mysql_store ms 
group by Department; 

select NodePathNameFull ,COUNT(1)
from mysql_store ms 
group by NodePathNameFull;


select NodePathName ,COUNT(1)
from mysql_store ms 
group by NodePathName 