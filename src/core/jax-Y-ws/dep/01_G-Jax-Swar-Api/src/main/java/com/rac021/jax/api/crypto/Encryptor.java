
package com.rac021.jax.api.crypto ;

/**
 *
 * @author yahiaoui
 */
import javax.crypto.Cipher ;
import javax.crypto.spec.SecretKeySpec ;
import javax.crypto.BadPaddingException ;
import javax.crypto.spec.IvParameterSpec ;
import java.security.InvalidKeyException ;
import javax.crypto.NoSuchPaddingException ;
import java.security.NoSuchAlgorithmException ;
import javax.crypto.IllegalBlockSizeException ;
import java.security.InvalidAlgorithmParameterException ;

/**
 *
 * @author ptcherniati
 */
public class Encryptor {

    private  Cipher          cipher         ;
    private  IvParameterSpec ivSpec         ;
    private  byte[]          ivBytes        ;
    private  SecretKeySpec   secretKeySpec  ;

    private static final String CRYPTO_MODE = "AES/CBC/PKCS5Padding" ;

    public Encryptor( String password ) {
        try {
            ivBytes = new byte[]{10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10} ;
            secretKeySpec = new SecretKeySpec(password.getBytes("UTF-8"), "AES")     ;
            ivSpec        = new IvParameterSpec(ivBytes) ;
        } catch ( Exception ex ) {
            ex.printStackTrace() ; 
        }
    }

    public void initEncryptMode() {
        try {
            cipher = Cipher.getInstance(CRYPTO_MODE) ;
            cipher.init(Cipher.ENCRYPT_MODE, secretKeySpec, ivSpec) ;
        } catch ( InvalidAlgorithmParameterException | InvalidKeyException |
                  NoSuchAlgorithmException           | NoSuchPaddingException ex ) {
            ex.printStackTrace() ;
        }
    }

    public void initDecryptMode() {
        try {
            cipher = Cipher.getInstance(CRYPTO_MODE) ;
            cipher.init(Cipher.DECRYPT_MODE, secretKeySpec, ivSpec) ;
        } catch ( InvalidAlgorithmParameterException | InvalidKeyException       |
                  NoSuchAlgorithmException           | NoSuchPaddingException ex ) {
            ex.printStackTrace() ;
        }
    }

   
    public byte[] aes128CBC7Encrypt(byte[] toEncrypt, CipherOperation co) {
        try {
            if ( co.equals(CipherOperation.dofinal) ) {
                return cipher.doFinal(toEncrypt) ;
            } else {
                return cipher.update(toEncrypt) ;
            }
        } catch (BadPaddingException | IllegalBlockSizeException ex) {
            ex.printStackTrace() ;
            return null ;
        }
    }

    public byte[] aes128CBC7Decrypt(byte[] encryptedMessage, CipherOperation co) {
        try {
            if (co.equals(CipherOperation.dofinal))     {
                return cipher.doFinal(encryptedMessage) ;
            } else {
                return cipher.update(encryptedMessage)  ;
            }
        } catch (BadPaddingException | IllegalBlockSizeException ex ) {
            ex.printStackTrace() ; 
            return null ;
        }
    }

    public Cipher getCipher() {
        return cipher ;
    }

    public void setCipher(Cipher cipher) {
        this.cipher = cipher ;
    }

    public IvParameterSpec getIvSpec() {
        return ivSpec ;
    }

    public void setIvSpec(IvParameterSpec ivSpec) {
        this.ivSpec = ivSpec ;
    }

}
