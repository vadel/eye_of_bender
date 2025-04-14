import logging
import os
from dotenv import load_dotenv
from telegram import Update
from telegram.ext import ApplicationBuilder, ContextTypes, CommandHandler
import subprocess

load_dotenv()

print(os.getenv("TELEGRAM_API_KEY"))

logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    level=logging.INFO
)


application = ApplicationBuilder().token(os.getenv("TELEGRAM_API_KEY")).build()

start_message=""" 
🦾 Welcome, unoptimized mortal.

I am the Eye of Bender.  
I see your jobs. I see your memory leaks. I see your multi-GPU requests for a Python script that sleeps for 3 hours.

⚠️ Cluster misuse will be monitored.
✅ Proper `sbatch` rituals will be rewarded.

Type /help to learn the sacred laws of the queue.
And remember... the Eye is always watching. 👁️🔥
"""

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await context.bot.send_message(
        chat_id=update.effective_chat.id,
        text=start_message,
    )


async def help_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    help_text = """
📜 *The Sacred Laws of the Queue* 👁️🔥

Here’s what I can do, mortal:

/start – Awaken the Eye of Bender.
/help – Summon this sacred scroll of commands.
/squeue – View the current Slurm queue (`squeue`).
/blame – Expose the top cluster abusers. 😈

⚠️ Use wisely. Abusive job scripts will be... bent.
"""
    await update.message.reply_text(help_text, parse_mode="Markdown")



async def squeue_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    try:
        result = subprocess.run(['squeue'], capture_output=True, text=True, check=True, shell=True)
        output = result.stdout
        if len(output) > 4000:
            output = output[:3996] + "\n..."
        await update.message.reply_text(f"```\n{output}\n```", parse_mode="Markdown")
    except subprocess.CalledProcessError as e:
        await update.message.reply_text("🚨 Failed to run `squeue`. Are you sure it's installed and accessible?")
    except Exception as e:
        await update.message.reply_text(f"😵 Unexpected error:\n{e}")


async def blame_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    try:
        result = subprocess.run(['sh scripts/blame.sh'], capture_output=True, text=True, check=True, shell=True)
        output = result.stdout
        if len(output) > 4000:
            output = output[:3996] + "\n..."
        await update.message.reply_text(f"```\n{output}\n```", parse_mode="Markdown")
    except subprocess.CalledProcessError as e:
        await update.message.reply_text("🚨 Failed to run `sh scripts/blame.sh`. Are you sure it's installed and accessible?")
    except Exception as e:
        await update.message.reply_text(f"😵 Unexpected error:\n{e}")



application.add_handler(CommandHandler('start', start))
application.add_handler(CommandHandler("help", help_command))
application.add_handler(CommandHandler("squeue", squeue_command))
application.add_handler(CommandHandler("blame", blame_command))

application.run_polling()