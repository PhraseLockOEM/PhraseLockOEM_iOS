#ifndef PhraseLockDefines_h
#define PhraseLockDefines_h

#pragma mark - PLProtocol data types -

typedef struct {
  uint32_t	index;
  uint32_t	valid;
  uint8_t 	iv[16];
  uint8_t 	aeskey[32];
} t_keyrecord;

typedef struct {
  uint32_t	crc;
  t_keyrecord	keyrecord;
} t_keystoreobj;

typedef struct {
  uint8_t serviceUUID[16];
  uint8_t priv[32];
  uint8_t publ[2][32];
} t_keyblock;

typedef struct {
  uint32_t	crc;
  uint32_t	reservedFF;			// Do not modify this value!
  t_keyblock	keyblock;
} t_otpkeyblock;

typedef enum {
  VERIFY_UPDATE 		= 0x01, 	// Just verify an available update
  INSTALL_UPDATE 		= 0x02,		// Install update if it is newer
  FORCE_UPDATE 		= 0x03,		// Forced installation
}PL_UPDATE_MODE;

typedef enum {
  RETURN_USB_MODE 	= 0x00,						// NO USB - Not yet implemented
  HID_USB 			= 0x01,						// HID Keyboard
  FDO_USB 			= 0x02,						// FIDO Support
  RAW_USB 			= 0x04,						// RAW Support
  
  CHF_USB 			= (HID_USB | FDO_USB),		// Composit Device Support (HID_USB | FDO_USB)
  CHR_USB 			= (HID_USB | RAW_USB),		// Composit Device Support (HID_USB | RAW_USB)
}pl_usbmode;

typedef enum {
  CT2_USER_MSG 		= 0x00,		// Message to the user
  CT2_USER_ACTION		= 0x01,		// Action required by user
}ctap2AlertType;


#endif /* PhraseLockDefines_h */
