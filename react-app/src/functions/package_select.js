
import { setPackage } from '../store/betting_store';
import { DEVNET_PACKAGE, MAINNET_PACKAGE } from "../package_info/packages"

export const loadPackages = async (dispatch) => {
    let packageString = "pass";
    dispatch(setPackage(packageString.toString()))

return packageString;
}

export const loadPackagesDevnet = async (dispatch) => {

    dispatch(setPackage(DEVNET_PACKAGE))
return DEVNET_PACKAGE;
}

export const loadPackagesMainnet = async (dispatch) => {

    dispatch(setPackage(MAINNET_PACKAGE));
return MAINNET_PACKAGE;
}