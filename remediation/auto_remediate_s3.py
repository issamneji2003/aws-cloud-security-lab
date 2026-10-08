import boto3
import logging

# Configuration des logs pour tracer les actions de remédiation du SOC
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def check_and_remediate_s3_bucket(bucket_name):
    """
    Vérifie si un compartiment S3 possède des accès publics ouverts 
    et applique automatiquement la remédiation (bloque l'accès public).
    """
    s3_client = boto3.client('s3')
    
    logger.info(f"Vérification de la posture de sécurité pour le bucket : {bucket_name}")
    
    try:
        # Récupération de la configuration actuelle du blocage d'accès public
        response = s3_client.get_public_access_block(Bucket=bucket_name)
        config = response.get('PublicAccessBlockConfiguration', {})
        
        # Vérification si une des options de sécurité est désactivée (faille détectée)
        if not all([
            config.get('BlockPublicAcls'),
            config.get('IgnorePublicAcls'),
            config.get('BlockPublicPolicy'),
            config.get('RestrictPublicBuckets')
        ]):
            logger.warning(f"[ALERTE SOC] Le bucket {bucket_name} présente des configurations d'accès public risquées !")
            logger.info(f"Application de la remédiation automatique...")
            
            # Application de la remédiation : verrouillage total des accès publics
            s3_client.put_public_access_block(
                Bucket=bucket_name,
                PublicAccessBlockConfiguration={
                    'BlockPublicAcls': True,
                    'IgnorePublicAcls': True,
                    'BlockPublicPolicy': True,
                    'RestrictPublicBuckets': True
                }
            )
            logger.info(f"[SUCCÈS] Remédiation appliquée : Le bucket {bucket_name} a été sécurisé avec succès.")
        else:
            logger.info(f"[CONFORME] Le bucket {bucket_name} est déjà totalement sécurisé.")
            
    except Exception as e:
        logger.error(f"Erreur lors de l'audit ou de la remédiation du bucket {bucket_name}: {str(e)}")

if __name__ == "__main__":
    # Remplacer par le nom de ton bucket de lab
    target_bucket = "mon-lab-securite-s3-issamneji"
    check_and_remediate_s3_bucket(target_bucket)