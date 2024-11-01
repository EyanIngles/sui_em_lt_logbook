import { createSlice } from '@reduxjs/toolkit'

export const packageInfo = createSlice({
    name: 'packageInfo',
    initialState: {
        package: null,
        other: null,
    },
    reducers: {
        setPackage: (state, action) => {
            state.package = action.payload
        },
        setOther: (state, action) => {
            state.other = action.payload
        },
        
    }
})

export const { setPackage, setOther } = packageInfo.actions;

export default packageInfo.reducer;