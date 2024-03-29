# Sui Move Q1 Cohort

## Exercises

- ### [Prerequisite exercise]
    - [Entry Functions]
    - [Shared Object]
    - [Transfer]
    - [Custom transfer]
    - [Events]
    - [One Time Witness]
    - [Object Display]
    - [Capability]
- ### [Enrollment dApp exercise]
    - [Airdrop]
    - [Enroll]
    - [Keygen]
    - [Transfer]
- ### [Bank exercise]
    - [Bank]
    - [Bank tests]

[Prerequisite exercise]: ./prereqs
[Entry Functions]: ./prereqs/sources/entry_function.move
[Shared Object]: ./prereqs/sources/shared_object.move
[Transfer]: ./prereqs/sources/transfer.move
[Custom transfer]: ./prereqs/sources/custom_transfer.move
[Events]: ./prereqs/sources/events.move
[One Time Witness]: ./prereqs/sources/one_time_witness.move
[Object Display]: ./prereqs/sources/object_display.move
[Capability]: ./prereqs/sources/capability.move

[Enrollment dApp exercise]: ./enrollment
[Airdrop]: ./enrollment/airdrop.ts
[Enroll]: ./enrollment/enroll.ts
[Keygen]: ./enrollment/keygen.ts
[Transfer]: ./enrollment/transfer.ts

[Bank exercise]: ./bank
[Bank]: ./bank/sources/bank.move
[Bank tests]: ./bank/sources/bank_tests.move


## Building your package


Make sure your terminal or console is in the directory that contains your package. Use the following command to build your package:
```
sui move build
```
A successful build returns a response similar to the following:

```
UPDATING GIT DEPENDENCY https://github.com/MystenLabs/sui.git
INCLUDING DEPENDENCY Sui
INCLUDING DEPENDENCY MoveStdlib
BUILDING {package name}
```

If the build fails, you can use the verbose error messaging in output to troubleshoot and resolve root issues.
