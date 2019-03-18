# GoldTaker

Phase 1 :: Base
1. Command line actions only  (/GT {Gold_Limit}; /GoldTaker {Gold_Limit})
2. Upon opening Mailbox indicate addon ready for use (print message to screen)
3. Only run if mailbox contains more than 50 items, display message indicating process cancelled if 50 or less
4. Use slash command to enter gold amount, if in-game mail is equal or less than that amount and mailbox is greater than 50 items then system will retrieve the mail
5. Display in chat window the records that were pulled
6. Display total in chat window

Phase 2 :: Localization
1. Add localization tables
2. Update print messages to pull from localization

Phase 3 :: GUI & SavedVariables
1. Create SavedVariables file
2. Build UI frames to display the following:
2a. Last gold limit set
2b. Recommended Gold limits based on records found within current mail 
2c. Buttons to run process
3. Store last gold limit set and record transactions to savedvariables
