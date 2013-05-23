/**
 * File: War3Source_Money.inc
 * Description: Interface to the currency system
 * Author(s): War3Source Team  
 */

enum W3CurrencyMode {
    CURRENCY_MODE_WAR3_GOLD = 0,
    CURRENCY_MODE_DORRAR    = 1
};

/**
 * Retrieve the currently set currency mode as defined by the cvar war3_currency_mode
 * 
 * CURRENCY_MODE_WAR3_GOLD  War3 Gold
 * CURRENCY_MODE_DORRAR     $ in Counter-Strike Source or Team Fortress 2 MVM mode
 */
native W3CurrencyMode:War3_GetCurrencyMode();

/**
 * Retrieve the amount of currency this player has
 */
native War3_GetCurrency(client);


/**
 * Change the currency of this player to a new value
 */
native War3_SetCurrency(client, newCurrency);