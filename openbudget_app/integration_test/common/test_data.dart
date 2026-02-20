/// Test fixtures used across Patrol E2E tests.
abstract final class TestData {
  // Auth
  static const validEmail = 'test@openbudget.app';
  static const validPassword = 'password123';

  // Budget
  static const budgetName = 'My First Budget';

  // Accounts
  static const checkingAccountName = 'Main Checking';
  static const savingsAccountName = 'Emergency Fund';
  static const creditCardAccountName = 'Visa Rewards';
  static const accountTypeChecking = 'checking';
  static const accountTypeSavings = 'savings';
  static const accountTypeCreditCard = 'creditCard';

  // Transactions
  static const expenseDescription = 'Grocery Store';
  static const incomeDescription = 'Monthly Salary';
  static const transferDescription = 'To Savings';
  static const expenseAmountCents = 5499;
  static const incomeAmountCents = 350000;
}
