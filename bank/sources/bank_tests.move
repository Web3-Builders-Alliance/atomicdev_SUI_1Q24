#[test_only]
module bank::bank_tests {
    //use std::debug;
    use sui::sui::SUI;
    use sui::test_utils::{assert_eq};
    use sui::coin::{Self};
    use sui::test_scenario;
    use bank::bank::{Self, Bank, OwnerCap, ENotEnoughBalance};

    const ADMIN: address = @0xAA;
    const USER: address = @0xBB;

    #[test]
    fun test_init_success() {

        let scenario_val = test_scenario::begin(ADMIN);

        let scenario = &mut scenario_val;
        {
            let ctx = test_scenario::ctx(scenario);
            bank::init_for_testing(ctx);
        };

        test_scenario::next_tx(scenario, ADMIN);
        {
            let owner_cap = test_scenario::take_from_sender<OwnerCap>(scenario);
            let tested_bank = test_scenario::take_shared<Bank>(scenario);

            assert_eq(bank::admin_balance(&tested_bank), 0);

            test_scenario::return_to_sender(scenario, owner_cap);
            test_scenario::return_shared(tested_bank);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_deposit_success() {
        let deposit_amount = 100;

        let scenario_val = init_test_helper();
        let scenario = &mut scenario_val;

        deposit_test_helper(scenario, USER, deposit_amount, 5);

        test_scenario::end(scenario_val);
    }

    #[test, expected_failure]
    fun test_deposit_fail() {
        let scenario_val = init_test_helper();
        let scenario = &mut scenario_val;

        deposit_test_helper(scenario, USER, 100, 6);

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_withdraw_success() {
        let deposit_amount = 100;

        let scenario_val = init_test_helper();
        let scenario = &mut scenario_val;

        deposit_test_helper(scenario, USER, 100, 5);

        test_scenario::next_tx(scenario, USER);
        {
            let tested_bank = test_scenario::take_shared<Bank>(scenario);

            let expected_admin_deposite: u64 = (deposit_amount * (bank::fee(&tested_bank) as u64)) / 100;
            let user_balance = bank::user_balance(&tested_bank, USER);

            assert_eq(user_balance, deposit_amount - expected_admin_deposite);

            let withdraw_coin = bank::withdraw(&mut tested_bank, test_scenario::ctx(scenario));
            assert_eq(coin::value(&withdraw_coin), deposit_amount - expected_admin_deposite);

            coin::burn_for_testing(withdraw_coin);
            test_scenario::return_shared(tested_bank);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_claim_success() {
        let deposit_amount = 100;

        let scenario_val = init_test_helper();
        let scenario = &mut scenario_val;

        deposit_test_helper(scenario, USER, deposit_amount, 5);

        test_scenario::next_tx(scenario, ADMIN);
        {
            let tested_bank = test_scenario::take_shared<Bank>(scenario);
            let expected_admin_deposite: u64 = (deposit_amount * (bank::fee(&tested_bank) as u64)) / 100;

            let owner_cap = test_scenario::take_from_sender<OwnerCap>(scenario);
            let withdraw_coin = bank::claim(&owner_cap, &mut tested_bank, test_scenario::ctx(scenario));
            assert_eq(coin::burn_for_testing(withdraw_coin), expected_admin_deposite);

            test_scenario::return_shared(tested_bank);
            test_scenario::return_to_sender(scenario, owner_cap);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_partial_withdraw_success() {

        let scenario_val = init_test_helper();
        let scenario = &mut scenario_val;

        deposit_test_helper(scenario, USER, 100, 5);

        test_scenario::next_tx(scenario, USER);
        {
            let tested_bank = test_scenario::take_shared<Bank>(scenario);
            let withdraw_coin = bank::partial_withdraw(&mut tested_bank, 50, test_scenario::ctx(scenario));

            assert_eq(coin::burn_for_testing(withdraw_coin), 50);
            test_scenario::return_shared(tested_bank);
        };

        test_scenario::next_tx(scenario, USER);
        {
            let tested_bank = test_scenario::take_shared<Bank>(scenario);
            assert_eq(bank::user_balance(&tested_bank, USER), 45);

            test_scenario::return_shared(tested_bank);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    #[expected_failure(abort_code = ENotEnoughBalance)]
    fun test_partial_withdraw_not_enough_balance() {
        let deposit_amount = 100;
        let scenario_val = init_test_helper();
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, USER);
        {
            let tested_bank = test_scenario::take_shared<Bank>(scenario);
            let deposit_coin = sui::coin::mint_for_testing<SUI>(
                deposit_amount,
                test_scenario::ctx(scenario)
            );

            bank::deposit(&mut tested_bank, deposit_coin, test_scenario::ctx(scenario));
            test_scenario::return_shared(tested_bank);
        };

        test_scenario::next_tx(scenario, USER);
        {
            let tested_bank = test_scenario::take_shared<Bank>(scenario);
            let expected_admin_deposite: u64 = (deposit_amount * (bank::fee(&tested_bank) as u64)) / 100;
            let user_balance = bank::user_balance(&tested_bank, USER);

            assert_eq(user_balance, deposit_amount - expected_admin_deposite);

            let withdraw_coin = bank::partial_withdraw(&mut tested_bank, 250, test_scenario::ctx(scenario));
            assert_eq(coin::value(&withdraw_coin), 50);

            coin::burn_for_testing(withdraw_coin);
            test_scenario::return_shared(tested_bank);
        };

        test_scenario::end(scenario_val);
    }


    fun init_test_helper() : test_scenario::Scenario{
        let scenario_val = test_scenario::begin(ADMIN);
        let scenario = &mut scenario_val;
        {
            bank::init_for_testing(test_scenario::ctx(scenario));
        };
        scenario_val
    }

    fun deposit_test_helper(scenario: &mut test_scenario::Scenario, addr:address, amount:u64, fee_percent:u64) {
        test_scenario::next_tx(scenario, addr);
        {
            let bank = test_scenario::take_shared<Bank>(scenario);
            bank::deposit(&mut bank, coin::mint_for_testing(amount, test_scenario::ctx(scenario)), test_scenario::ctx(scenario));

            let (user_amount, admin_amount) = calculate_fee_helper(amount, fee_percent);

            assert_eq(bank::user_balance(&bank, addr), user_amount);
            assert_eq(bank::admin_balance(&bank), admin_amount);

            test_scenario::return_shared(bank);
        };
    }

    fun calculate_fee_helper(amount:u64, fee_percent:u64) : (u64, u64) {
        let fee = (amount * fee_percent) / 100;
        (amount - fee, fee)
    }
}
