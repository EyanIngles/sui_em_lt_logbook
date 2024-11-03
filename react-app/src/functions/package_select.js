
import { setPackage, setStorageId, setCurrentAccount } from '../store/item_store';
import { DEVNET_PACKAGE, MAINNET_PACKAGE, MAINNET_STORAGE_ID, DEVNET_STORAGE_ID } from "../package_info/packages"

export const loadPackages = async (dispatch) => {
    let packageString = "pass";
    dispatch(setPackage(packageString.toString()))

return packageString;
}

export const loadPackagesDevnet = async (dispatch) => {

    dispatch(setPackage(DEVNET_PACKAGE))
    dispatch(setStorageId(DEVNET_STORAGE_ID))
return [DEVNET_PACKAGE, DEVNET_STORAGE_ID];
}

export const loadPackagesMainnet = async (dispatch) => {

    dispatch(setPackage(MAINNET_PACKAGE));
    dispatch(setStorageId(MAINNET_STORAGE_ID))

return [MAINNET_PACKAGE, MAINNET_STORAGE_ID];
}

export const loadAccount = async (account, dispatch) => {

    dispatch(setCurrentAccount(account))
return account;
}