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

  // Tax
  static const taxProfileTitle = 'Tax profile';
  static const taxSetupTitle = 'Set up taxes';
  static const taxBalanceDue = 'Balance due';
  static const taxDisclaimer =
      'Guidance only, not tax advice. Check figures with a qualified adviser '
      'before filing.';
  static const taxYearLabel = 'Tax year 2026/27';
}
