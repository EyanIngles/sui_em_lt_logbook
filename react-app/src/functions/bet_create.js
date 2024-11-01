import { setOther } from "../store/betting_store"

export const loadOther = async (dispatch) => {
    let packageString = "setup 1 is here";
    dispatch(setOther(packageString.toString()))

return packageString;
}