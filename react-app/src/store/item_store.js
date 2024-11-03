import { createSlice } from '@reduxjs/toolkit'

export const packageInfo = createSlice({
    name: 'packageInfo',
    initialState: {
        package: null,
        storageId: null,
        other: null,
        currentAccount: null,
    },
    reducers: {
        setPackage: (state, action) => {
            state.package = action.payload
        },
        setStorageId: (state, action) => {
            state.storageId = action.payload
        },
        setOther: (state, action) => {
            state.other = action.payload
        },
        setCurrentAccount: (state, action) => {
            state.currentAccount = action.payload
        },
        
    }
})

export const { setPackage, setOther, setCurrentAccount, setStorageId } = packageInfo.actions;

export default packageInfo.reducer;