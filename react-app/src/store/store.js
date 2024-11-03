import { configureStore } from '@reduxjs/toolkit'
import packageInfo from './item_store'

export const store = configureStore({
  reducer: {
    packageInfo,
  },
  middleware: getDefaultMiddleware =>
    getDefaultMiddleware({
        serializableCheck: false
    })
})
