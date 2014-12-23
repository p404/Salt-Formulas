##[Salt](http://www.saltstack.com/community/)-Formulas 
This repository contains my own salt formulas and others collected from the web. 

  * Certificate Authority generation 
  * Elk Stack
  * Sensu Monitoring
  * Ruby/RVM
  * and more!

If you have any questions about this salt formulas, please feel free to drop me an email at <paoc@sequel.ninja>


###TODO
- README.md update
- Top.sls order configuration 'include'
- User Managment state
- Refactor htpasswd with the htpasswd state
- IP Tables state support
- Refactor and use pillars.
- Generate the SSL cert ca self signed from salt module.
  - Execution of this on a salt state
  
  
####Issues
* Elk formula not working properly(random bug ordening states).
* Sensu conf needs debugging.